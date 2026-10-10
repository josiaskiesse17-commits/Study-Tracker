import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/task.dart';
import '../providers/task_controller.dart';

Future<void> showWorkDialog(
  BuildContext context,
  WidgetRef ref, {
  WorkItem? existing,
  String? fixedProjectId,
}) async {
  final isEditing = existing != null;
  final l10n = AppLocalizations.of(context)!;

  final titleController = TextEditingController(text: existing?.title ?? '');
  final descriptionController = TextEditingController(text: existing?.description ?? '');

  var selectedType = existing?.type ?? 'other';
  var selectedStatus = existing?.status ?? 'pending';
  var selectedPriority = existing?.priority ?? 'medium';
  DateTime? selectedDueDate = existing?.dueDate;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      var isSaving = false;

      return StatefulBuilder(
        builder: (context, setState) {
          final screenHeight = MediaQuery.sizeOf(context).height;

          return AlertDialog(
            title: Text(
              isEditing ? l10n.editWork : l10n.createWork,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: screenHeight * 0.55,
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        labelText: l10n.title,
                        prefixIcon: const Icon(Icons.title_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      minLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        labelText: l10n.description,
                        hintText: l10n.optional,
                        prefixIcon: const Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: l10n.type,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: [
                        DropdownMenuItem(value: 'homework', child: Text(l10n.homework)),
                        DropdownMenuItem(value: 'assignment', child: Text(l10n.assignment)),
                        DropdownMenuItem(value: 'reading', child: Text(l10n.reading)),
                        DropdownMenuItem(value: 'exercise', child: Text(l10n.exercise)),
                        DropdownMenuItem(value: 'exam', child: Text(l10n.exam)),
                        DropdownMenuItem(value: 'quiz', child: Text(l10n.quiz)),
                        DropdownMenuItem(value: 'practice', child: Text(l10n.practice)),
                        DropdownMenuItem(value: 'other', child: Text(l10n.other)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        labelText: l10n.status,
                        prefixIcon: const Icon(Icons.flag_outlined),
                      ),
                      items: [
                        DropdownMenuItem(value: 'pending', child: Text(l10n.pending)),
                        DropdownMenuItem(value: 'in_progress', child: Text(l10n.inProgress)),
                        DropdownMenuItem(value: 'completed', child: Text(l10n.completed)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      decoration: InputDecoration(
                        labelText: l10n.priority,
                        prefixIcon: const Icon(Icons.priority_high_rounded),
                      ),
                      items: [
                        DropdownMenuItem(value: 'low', child: Text(l10n.lowPriority)),
                        DropdownMenuItem(value: 'medium', child: Text(l10n.mediumPriority)),
                        DropdownMenuItem(value: 'high', child: Text(l10n.highPriority)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedPriority = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(
                        selectedDueDate == null
                            ? l10n.dueDate
                            : formatDate(selectedDueDate!),
                      ),
                      subtitle: Text(
                        selectedDueDate == null ? l10n.optional : l10n.tapToChange,
                      ),
                      trailing: selectedDueDate == null
                          ? null
                          : IconButton(
                              tooltip: l10n.removeDueDate,
                              onPressed: () => setState(() => selectedDueDate = null),
                              icon: const Icon(Icons.clear_rounded),
                            ),
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => selectedDueDate = date);
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
                    : () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();

                        final title = titleController.text.trim();

                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.titleRequired)),
                          );
                          return;
                        }

                        setState(() => isSaving = true);

                        try {
                          final description = descriptionController.text.trim();

                          if (isEditing) {
                            await ref
                                .read(taskControllerProvider.notifier)
                                .updateTask(
                                  taskId: existing.id,
                                  title: title,
                                  description: description.isEmpty ? null : description,
                                  courseId: existing.courseId,
                                  projectId: fixedProjectId ?? existing.projectId,
                                  type: selectedType,
                                  status: selectedStatus,
                                  priority: selectedPriority,
                                  dueDate: selectedDueDate,
                                );
                          } else {
                            await ref
                                .read(taskControllerProvider.notifier)
                                .createTask(
                                  title: title,
                                  description: description.isEmpty ? null : description,
                                  courseId: null,
                                  projectId: fixedProjectId,
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
                          if (!dialogContext.mounted) return;

                          setState(() => isSaving = false);

                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(l10n.failedToSaveWork(error.toString())),
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? l10n.saveChanges : l10n.create),
              ),
            ],
          );
        },
      );
    },
  );
}