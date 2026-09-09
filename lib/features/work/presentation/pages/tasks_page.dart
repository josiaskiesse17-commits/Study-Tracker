import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/task.dart';
import '../providers/task_controller.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workAsync = ref.watch(taskControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.work,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filled(
              onPressed: () => _showWorkDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              tooltip: l10n.createWorkItem,
            ),
          ),
        ],
      ),
      body: workAsync.when(
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
        data: (items) {
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
                  const SizedBox(height: 110),
                  Icon(
                    Icons.checklist_rounded,
                    size: 72,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      l10n.noWorkYet,
                      style: const TextStyle(
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
                      l10n.addWorkDescription,
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
                        _showWorkDialog(context, ref);
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.addWork),
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
                12,
                16,
                24,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                              PopupMenuButton<String>(
                                tooltip: l10n.workActions,
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showWorkDialog(
                                      context,
                                      ref,
                                      item: item,
                                    );
                                  }

                                  if (value == 'delete') {
                                    _confirmDeleteWork(
                                      context,
                                      ref,
                                      item.id,
                                      item.title,
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.edit_rounded,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(l10n.edit),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.delete_outline,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(l10n.delete),
                                      ],
                                    ),
                                  ),
                                ],
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
                              _WorkChip(
                                label: _typeLabel(
                                  item.type,
                                  l10n,
                                ),
                                icon: Icons.category_outlined,
                              ),
                              _WorkChip(
                                label: _statusLabel(
                                  item.status,
                                  l10n,
                                ),
                                icon: Icons.flag_outlined,
                              ),
                              _WorkChip(
                                label: _priorityLabel(
                                  item.priority,
                                  l10n,
                                ),
                                icon: Icons.priority_high_rounded,
                              ),
                              if (item.dueDate != null)
                                _WorkChip(
                                  label: _formatDate(
                                    item.dueDate!,
                                  ),
                                  icon: Icons.calendar_today_outlined,
                                ),
                            ],
                          ),
                        ],
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

  Future<void> _confirmDeleteWork(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteWork),
          content: Text(
            l10n.deleteWorkConfirmation(title),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.delete),
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
        .deleteTask(id);
  }

  void _showWorkDialog(
    BuildContext context,
    WidgetRef ref, {
    WorkItem? item,
  }) {
    final isEditing = item != null;
    final l10n = AppLocalizations.of(context)!;

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
            final screenHeight = MediaQuery.sizeOf(context).height;

            return AlertDialog(
              title: Text(
                isEditing ? l10n.editWork : l10n.createWork,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: screenHeight * 0.55,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        textCapitalization:
                            TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: l10n.title,
                          prefixIcon:
                              const Icon(Icons.title_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        minLines: 3,
                        textCapitalization:
                            TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          hintText: l10n.optional,
                          prefixIcon:
                              const Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: InputDecoration(
                          labelText: l10n.type,
                          prefixIcon:
                              const Icon(Icons.category_outlined),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'homework',
                            child: Text(l10n.homework),
                          ),
                          DropdownMenuItem(
                            value: 'assignment',
                            child: Text(l10n.assignment),
                          ),
                          DropdownMenuItem(
                            value: 'reading',
                            child: Text(l10n.reading),
                          ),
                          DropdownMenuItem(
                            value: 'exercise',
                            child: Text(l10n.exercise),
                          ),
                          DropdownMenuItem(
                            value: 'exam',
                            child: Text(l10n.exam),
                          ),
                          DropdownMenuItem(
                            value: 'quiz',
                            child: Text(l10n.quiz),
                          ),
                          DropdownMenuItem(
                            value: 'practice',
                            child: Text(l10n.practice),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text(l10n.other),
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
                        decoration: InputDecoration(
                          labelText: l10n.status,
                          prefixIcon:
                              const Icon(Icons.flag_outlined),
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
                            setState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPriority,
                        decoration: InputDecoration(
                          labelText: l10n.priority,
                          prefixIcon:
                              const Icon(Icons.priority_high_rounded),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'low',
                            child: Text(l10n.lowPriority),
                          ),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Text(l10n.mediumPriority),
                          ),
                          DropdownMenuItem(
                            value: 'high',
                            child: Text(l10n.highPriority),
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
                              ? l10n.dueDate
                              : _formatDate(selectedDueDate!),
                        ),
                        subtitle: Text(
                          selectedDueDate == null
                              ? l10n.optional
                              : l10n.tapToChange,
                        ),
                        trailing: selectedDueDate == null
                            ? null
                            : IconButton(
                                tooltip: l10n.removeDueDate,
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
                          FocusScope.of(context).unfocus();

                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                selectedDueDate ?? DateTime.now(),
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
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();

                          final title =
                              titleController.text.trim();

                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.titleRequired,
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
                                    taskId: item.id,
                                    title: title,
                                    description:
                                        description.isEmpty
                                            ? null
                                            : description,
                                    courseId: item.courseId,
                                    projectId: item.projectId,
                                    type: selectedType,
                                    status: selectedStatus,
                                    priority:
                                        selectedPriority,
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
                                    type: selectedType,
                                    status: selectedStatus,
                                    priority:
                                        selectedPriority,
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
                                  l10n.failedToSaveWork(
                                    error.toString(),
                                  ),
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
                          isEditing
                              ? l10n.saveChanges
                              : l10n.create,
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

class _WorkChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _WorkChip({
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
    final l10n = AppLocalizations.of(context)!;

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
            Text(
              l10n.unableToLoadWork,
              style: const TextStyle(
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
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

String _typeLabel(
  String type,
  AppLocalizations l10n,
) {
  switch (type) {
    case 'homework':
      return l10n.homework;
    case 'assignment':
      return l10n.assignment;
    case 'reading':
      return l10n.reading;
    case 'exercise':
      return l10n.exercise;
    case 'exam':
      return l10n.exam;
    case 'quiz':
      return l10n.quiz;
    case 'practice':
      return l10n.practice;
    default:
      return l10n.other;
  }
}

String _statusLabel(
  String status,
  AppLocalizations l10n,
) {
  switch (status) {
    case 'in_progress':
      return l10n.inProgress;
    case 'completed':
      return l10n.completed;
    default:
      return l10n.pending;
  }
}

String _priorityLabel(
  String priority,
  AppLocalizations l10n,
) {
  switch (priority) {
    case 'high':
      return l10n.highPriority;
    case 'low':
      return l10n.lowPriority;
    default:
      return l10n.mediumPriority;
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}