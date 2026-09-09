import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/task_controller.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filled(
              onPressed: () => _showTaskDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Create task',
            ),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorState(
          error: error.toString(),
          onRetry: () {
            ref
                .read(taskControllerProvider.notifier)
                .refreshTasks();
          },
        ),
        data: (tasks) {
          if (tasks.isEmpty) {
            return RefreshIndicator(
              onRefresh: () {
                return ref
                    .read(taskControllerProvider.notifier)
                    .refreshTasks();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 110),
                  Icon(
                    Icons.task_alt_rounded,
                    size: 72,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'No tasks yet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: Text(
                      'Add tasks to organize what you need to accomplish.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: FilledButton.icon(
                      onPressed: () {
                        _showTaskDialog(context, ref);
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create task'),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: task.completed
                        ? colors.surfaceContainerLow
                        : colors.surfaceContainerHighest,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        try {
                          await ref
                              .read(
                                taskControllerProvider.notifier,
                              )
                              .toggleTask(task);
                        } catch (error) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to update task: $error',
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: task.completed,
                              onChanged: (_) async {
                                try {
                                  await ref
                                      .read(
                                        taskControllerProvider
                                            .notifier,
                                      )
                                      .toggleTask(task);
                                } catch (error) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to update task: $error',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      decoration:
                                          task.completed
                                              ? TextDecoration
                                                  .lineThrough
                                              : null,
                                      color: task.completed
                                          ? colors
                                              .onSurfaceVariant
                                          : null,
                                    ),
                                  ),
                                  if (task.description != null &&
                                      task.description!
                                          .trim()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 5),
                                    Text(
                                      task.description!,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colors
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: task.completed
                                          ? colors
                                              .secondaryContainer
                                          : colors
                                              .primaryContainer,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      task.completed
                                          ? 'Completed'
                                          : 'To do',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w700,
                                        color: task.completed
                                            ? colors
                                                .onSecondaryContainer
                                            : colors
                                                .onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showTaskDialog(
                                    context,
                                    ref,
                                    task: task,
                                  );
                                }

                                if (value == 'delete') {
                                  _confirmDeleteTask(
                                    context,
                                    ref,
                                    task.id,
                                    task.title,
                                  );
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_rounded),
                                      SizedBox(width: 12),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline),
                                      SizedBox(width: 12),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteTask(
    BuildContext context,
    WidgetRef ref,
    String taskId,
    String taskTitle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete task?'),
          content: Text(
            'Are you sure you want to delete "$taskTitle"?',
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

    try {
      await ref
          .read(taskControllerProvider.notifier)
          .deleteTask(taskId);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete task: $error'),
        ),
      );
    }
  }

  void _showTaskDialog(
    BuildContext context,
    WidgetRef ref, {
    dynamic task,
  }) {
    final isEditing = task != null;

    final titleController = TextEditingController(
      text: isEditing ? task.title : '',
    );

    final descriptionController = TextEditingController(
      text: isEditing ? task.description ?? '' : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        var isSaving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit task' : 'Create task',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        prefixIcon:
                            Icon(Icons.task_alt_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Optional',
                        prefixIcon:
                            Icon(Icons.notes_rounded),
                      ),
                    ),
                  ],
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
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Task title is required.',
                                ),
                              ),
                            );
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
                                    taskId: task.id,
                                    title: title,
                                    description:
                                        description.isEmpty
                                            ? null
                                            : description,
                                    courseId: task.courseId,
                                    completed: task.completed,
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
                                  'Failed to save task: $error',
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

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to load tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}