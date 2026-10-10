import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_tracker/core/utils/date_format.dart';
import 'package:study_tracker/core/widgets/error_state.dart';
import 'package:study_tracker/features/work/presentation/widgets/work_labels.dart';
import 'package:study_tracker/l10n/app_localizations.dart';
import 'package:study_tracker/features/projects/domain/entities/milestone.dart';
import 'package:study_tracker/features/projects/presentation/providers/milestone_controller.dart';

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

  Future<void> _showMilestoneDialog({
    Milestone? milestone,
  }) async {
    final l10n = AppLocalizations.of(context)!;

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
                    ? l10n.newMilestone
                    : l10n.editMilestone,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.title,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.description,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: InputDecoration(
                        labelText: l10n.status,
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text(l10n.pending),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text(l10n.inProgress),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text(l10n.completed),
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
                      title: Text(l10n.dueDate),
                      subtitle: Text(
                        dueDate == null
                            ? l10n.noDueDate
                            : formatDate(dueDate!),
                      ),
                      trailing: IconButton(
                        tooltip: l10n.chooseDueDate,
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
                  child: Text(l10n.cancel),
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
                    milestone == null ? l10n.create : l10n.save,
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
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteMilestone),
          content: Text(
            l10n.deleteMilestoneConfirmation(milestone.title),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context)!;

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
              '${workStatusLabel(context, milestone.status)} • '
              '${milestone.dueDate == null ? l10n.noDueDate : formatDate(milestone.dueDate!)}',
            ),
          ],
        ),
        isThreeLine: true,

        // VISIBLE ACTION BUTTONS
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.edit,
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                _showMilestoneDialog(
                  milestone: milestone,
                );
              },
            ),
            IconButton(
              tooltip: l10n.delete,
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
    final l10n = AppLocalizations.of(context)!;

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
        label: Text(l10n.milestone),
      ),
      body: milestonesState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stackTrace) => ErrorState(
          message: l10n.couldNotLoadMilestones,
          error: error.toString(),
          onRetry: () => ref
              .read(milestoneControllerProvider.notifier)
              .refreshMilestones(widget.projectId),
        ),

        data: (milestones) {
          if (milestones.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_circle_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noMilestonesYet,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.createMilestoneDescription,
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