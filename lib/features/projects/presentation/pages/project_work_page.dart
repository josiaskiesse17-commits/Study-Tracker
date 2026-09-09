import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../work/domain/entities/task.dart';
import '../../../work/presentation/providers/task_controller.dart';

class ProjectWorkPage extends ConsumerWidget {
  final String projectId;
  final String projectName;

  const ProjectWorkPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workAsync = ref.watch(taskControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$projectName — Work',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showWorkDialog(context, ref);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add work'),
      ),
      body: workAsync.when(
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
                const SizedBox(height: 16),
                const Text(
                  'Unable to load project work.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(taskControllerProvider.notifier)
                        .refreshTasks();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (allItems) {
          final items = allItems
              .where(
                (item) => item.projectId == projectId,
              )
              .toList();

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () {
                return ref
                    .read(taskControllerProvider.notifier)
                    .refreshTasks();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.task_alt_rounded,
                    size: 72,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'No work for this project',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: Text(
                      'Add work items that belong to this project.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(taskControllerProvider.notifier)
                  .refreshTasks();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return _WorkCard(
                  item: item,
                  onEdit: () {
                    _showWorkDialog(
                      context,
                      ref,
                      item: item,
                    );
                  },
                  onDelete: () {
                    _confirmDelete(
                      context,
                      ref,
                      item,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WorkItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete work?'),
          content: Text(
            'Are you sure you want to delete "${item.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref
        .read(taskControllerProvider.notifier)
        .deleteTask(item.id);
  }

  void _showWorkDialog(
    BuildContext context,
    WidgetRef ref, {
    WorkItem? item,
  }) {
    final isEditing = item != null;

    final titleController = TextEditingController(
      text: item?.title ?? '',
    );

    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );

    var selectedType = item?.type ?? 'other';
    var selectedStatus = item?.status ?? 'pending';
    var selectedPriority = item?.priority ?? 'medium';
    DateTime? selectedDueDate = item?.dueDate;

    showDialog(
      context: context,
      builder: (dialogContext) {
        var isSaving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            final screenHeight =
                MediaQuery.sizeOf(context).height;

            return AlertDialog(
              title: Text(
                isEditing ? 'Edit work' : 'Add project work',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: screenHeight * 0.55,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          prefixIcon: Icon(
                            Icons.title_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Optional',
                          prefixIcon: Icon(
                            Icons.notes_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'homework',
                            child: Text('Homework'),
                          ),
                          DropdownMenuItem(
                            value: 'assignment',
                            child: Text('Assignment'),
                          ),
                          DropdownMenuItem(
                            value: 'reading',
                            child: Text('Reading'),
                          ),
                          DropdownMenuItem(
                            value: 'exercise',
                            child: Text('Exercise'),
                          ),
                          DropdownMenuItem(
                            value: 'exam',
                            child: Text('Exam'),
                          ),
                          DropdownMenuItem(
                            value: 'quiz',
                            child: Text('Quiz'),
                          ),
                          DropdownMenuItem(
                            value: 'practice',
                            child: Text('Practice'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(
                            Icons.flag_outlined,
                          ),
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
                            setState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: Icon(
                            Icons.priority_high_rounded,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'low',
                            child: Text('Low'),
                          ),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(
                            value: 'high',
                            child: Text('High'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedPriority = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.calendar_today_outlined,
                        ),
                        title: Text(
                          selectedDueDate == null
                              ? 'Due date'
                              : _formatDate(selectedDueDate!),
                        ),
                        subtitle: const Text('Optional'),
                        trailing: selectedDueDate == null
                            ? null
                            : IconButton(
                                tooltip: 'Remove due date',
                                onPressed: () {
                                  setState(() {
                                    selectedDueDate = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.clear_rounded,
                                ),
                              ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedDueDate ??
                                    DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (date != null) {
                            setState(() {
                              selectedDueDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final title =
                              titleController.text.trim();

                          if (title.isEmpty) {
                            return;
                          }

                          setState(() {
                            isSaving = true;
                          });

                          try {
                            final description =
                                descriptionController.text
                                    .trim();

                            if (isEditing) {
                              await ref
                                  .read(
                                    taskControllerProvider
                                        .notifier,
                                  )
                                  .updateTask(
                                    taskId: item.id,
                                    title: title,
                                    description:
                                        description.isEmpty
                                            ? null
                                            : description,
                                    courseId: item.courseId,
                                    projectId: projectId,
                                    type: selectedType,
                                    status: selectedStatus,
                                    priority: selectedPriority,
                                    dueDate: selectedDueDate,
                                  );
                            } else {
                              await ref
                                  .read(
                                    taskControllerProvider
                                        .notifier,
                                  )
                                  .createTask(
                                    title: title,
                                    description:
                                        description.isEmpty
                                            ? null
                                            : description,
                                    projectId: projectId,
                                    type: selectedType,
                                    status: selectedStatus,
                                    priority: selectedPriority,
                                    dueDate: selectedDueDate,
                                  );
                            }

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (error) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to save work: $error',
                                ),
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? 'Save changes' : 'Create',
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _WorkCard extends StatelessWidget {
  final WorkItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WorkCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit work',
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_rounded,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete work',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                  ),
                ),
              ],
            ),
            if (item.description != null &&
                item.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  label: _typeLabel(item.type),
                  icon: Icons.category_outlined,
                ),
                _Chip(
                  label: _statusLabel(item.status),
                  icon: Icons.flag_outlined,
                ),
                _Chip(
                  label: _priorityLabel(item.priority),
                  icon: Icons.priority_high_rounded,
                ),
                if (item.dueDate != null)
                  _Chip(
                    label: _formatDate(item.dueDate!),
                    icon: Icons.calendar_today_outlined,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Chip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
      ),
      label: Text(label),
    );
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'homework':
      return 'Homework';
    case 'assignment':
      return 'Assignment';
    case 'reading':
      return 'Reading';
    case 'exercise':
      return 'Exercise';
    case 'exam':
      return 'Exam';
    case 'quiz':
      return 'Quiz';
    case 'practice':
      return 'Practice';
    default:
      return 'Other';
  }
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

String _priorityLabel(String priority) {
  switch (priority) {
    case 'high':
      return 'High priority';
    case 'low':
      return 'Low priority';
    default:
      return 'Medium priority';
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}