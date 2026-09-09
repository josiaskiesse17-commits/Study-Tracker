import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/milestone.dart';
import '../providers/milestone_controller.dart';

class MilestonesPage extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const MilestonesPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<MilestonesPage> createState() =>
      _MilestonesPageState();
}

class _MilestonesPageState extends ConsumerState<MilestonesPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => ref
          .read(milestoneControllerProvider.notifier)
          .loadMilestones(widget.projectId),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'In progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final colors = Theme.of(context).colorScheme;

    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return colors.primary;
      default:
        return colors.secondary;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'No due date';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _showMilestoneDialog({
    Milestone? milestone,
  }) async {
    final titleController = TextEditingController(
      text: milestone?.title ?? '',
    );

    final descriptionController = TextEditingController(
      text: milestone?.description ?? '',
    );

    String status = milestone?.status ?? 'pending';
    DateTime? dueDate = milestone?.dueDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                milestone == null
                    ? 'New milestone'
                    : 'Edit milestone',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('In progress'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            status = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_today_rounded,
                      ),
                      title: const Text('Due date'),
                      subtitle: Text(
                        _formatDate(dueDate),
                      ),
                      trailing: IconButton(
                        tooltip: 'Choose due date',
                        icon: const Icon(
                          Icons.edit_calendar_rounded,
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                dueDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() {
                              dueDate = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child: Text(
                    milestone == null ? 'Create' : 'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) {
      titleController.dispose();
      descriptionController.dispose();
      return;
    }

    final controller =
        ref.read(milestoneControllerProvider.notifier);

    final description =
        descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim();

    if (milestone == null) {
      await controller.createMilestone(
        projectId: widget.projectId,
        title: titleController.text.trim(),
        description: description,
        status: status,
        dueDate: dueDate,
      );
    } else {
      await controller.updateMilestone(
        milestoneId: milestone.id,
        projectId: widget.projectId,
        title: titleController.text.trim(),
        description: description,
        status: status,
        dueDate: dueDate,
      );
    }

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> _deleteMilestone(
    Milestone milestone,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete milestone?'),
          content: Text(
            'Delete "${milestone.title}"? '
            'This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await ref
        .read(milestoneControllerProvider.notifier)
        .deleteMilestone(
          milestoneId: milestone.id,
          projectId: widget.projectId,
        );
  }

  Widget _buildMilestoneCard(
    BuildContext context,
    Milestone milestone,
  ) {
    final statusColor =
        _statusColor(context, milestone.status);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Icon(
          milestone.status == 'completed'
              ? Icons.check_circle_rounded
              : Icons.flag_circle_rounded,
          color: statusColor,
          size: 30,
        ),
        title: Text(
          milestone.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (milestone.description != null &&
                milestone.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(milestone.description!),
            ],
            const SizedBox(height: 6),
            Text(
              '${_statusLabel(milestone.status)} • '
              '${_formatDate(milestone.dueDate)}',
            ),
          ],
        ),
        isThreeLine: true,

        // VISIBLE ACTION BUTTONS
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Edit milestone',
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                _showMilestoneDialog(
                  milestone: milestone,
                );
              },
            ),
            IconButton(
              tooltip: 'Delete milestone',
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
              onPressed: () {
                _deleteMilestone(milestone);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final milestonesState =
        ref.watch(milestoneControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.projectName,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMilestoneDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Milestone'),
      ),
      body: milestonesState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Could not load milestones.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref
                      .read(
                        milestoneControllerProvider.notifier,
                      )
                      .refreshMilestones(widget.projectId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),

        data: (milestones) {
          if (milestones.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_circle_outlined,
                      size: 56,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No milestones yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Break this project into smaller goals.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(
                  milestoneControllerProvider.notifier,
                )
                .refreshMilestones(widget.projectId),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                100,
              ),
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                return _buildMilestoneCard(
                  context,
                  milestones[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}