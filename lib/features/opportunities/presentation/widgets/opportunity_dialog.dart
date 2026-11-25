import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services/notification_service.dart';
import '../../domain/entities/opportunity.dart';
import '../providers/opportunity_controller.dart';

Future<void> showOpportunityDialog({
  required BuildContext context,
  required WidgetRef ref,
  Opportunity? existing,
}) async {
  final isEditing = existing != null;
  final l10n = AppLocalizations.of(context)!;
  final notificationService = ref.read(notificationServiceProvider);

  final nameController = TextEditingController(text: existing?.name ?? '');
  final descriptionController = TextEditingController(
    text: existing?.description ?? '',
  );
  final organizerController = TextEditingController(
    text: existing?.organizer ?? '',
  );
  final urlController = TextEditingController(text: existing?.url ?? '');
  final eligibilityController = TextEditingController(
    text: existing?.eligibility ?? '',
  );
  final requirementsController = TextEditingController(
    text: existing?.requirements ?? '',
  );
  final notesController = TextEditingController(text: existing?.notes ?? '');
  final nextActionController = TextEditingController(
    text: existing?.nextAction ?? '',
  );

  var selectedType = existing?.type ?? OpportunityType.scholarship;
  var selectedStatus = existing?.status ?? OpportunityStatus.considering;
  var remindForDate = existing?.deadlineOrEventDate != null;
  var remindForNextAction = existing?.nextActionDueDate != null;
  DateTime? selectedDate = existing?.deadlineOrEventDate;
  DateTime? selectedNextActionDate = existing?.nextActionDueDate;

  // Ensure selected status is valid for the current type
  final initialValidStatuses = OpportunityStatus.forType(selectedType);
  if (!initialValidStatuses.contains(selectedStatus)) {
    selectedStatus = initialValidStatuses.first;
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      var isSaving = false;

      return StatefulBuilder(
        builder: (context, setState) {
          final screenHeight = MediaQuery.sizeOf(context).height;
          final colors = Theme.of(context).colorScheme;
          final validStatuses = OpportunityStatus.forType(selectedType);

          return AlertDialog(
            title: Text(
              isEditing ? l10n.editOpportunity : l10n.createOpportunity,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: screenHeight * 0.85,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.opportunityName,
                        hintText: l10n.opportunityNameRequired,
                        prefixIcon: const Icon(Icons.title_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<OpportunityType>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: l10n.type,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: OpportunityType.scholarship,
                          child: Text(l10n.scholarship),
                        ),
                        DropdownMenuItem(
                          value: OpportunityType.event,
                          child: Text(l10n.event),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedType = value;
                            selectedStatus = OpportunityStatus.forType(value)
                                .first;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<OpportunityStatus>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: l10n.status,
                        prefixIcon: const Icon(Icons.flag_outlined),
                      ),
                      items: validStatuses
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(_statusLabel(l10n, status)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.description,
                        hintText: l10n.optional,
                        prefixIcon: const Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: organizerController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.organizer,
                        hintText: l10n.optional,
                        prefixIcon: const Icon(Icons.person_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: urlController,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.url,
                        hintText: l10n.enterUrl,
                        prefixIcon: const Icon(Icons.link_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_rounded),
                      title: Text(l10n.deadlineOrEventDate),
                      subtitle: Text(
                        selectedDate == null
                            ? l10n.noDueDate
                            : formatDate(selectedDate!),
                      ),
                      trailing: selectedDate == null
                          ? null
                          : IconButton(
                              tooltip: l10n.cancel,
                              onPressed: () {
                                setState(() => selectedDate = null);
                              },
                              icon: const Icon(Icons.clear_rounded),
                            ),
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: eligibilityController,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.eligibility,
                        hintText: l10n.optional,
                        prefixIcon: const Icon(Icons.rule_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: requirementsController,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.requirements,
                        hintText: l10n.optional,
                        prefixIcon: const Icon(Icons.list_alt_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nextActionController,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.nextAction,
                        hintText: l10n.optional,
                        prefixIcon: const Icon(Icons.flag_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.schedule_rounded,
                        color: Colors.amber,
                      ),
                      title: Text(l10n.nextActionDueDate),
                      subtitle: Text(
                        selectedNextActionDate == null
                            ? l10n.noDueDate
                            : formatDate(selectedNextActionDate!),
                      ),
                      trailing: selectedNextActionDate == null
                          ? null
                          : IconButton(
                              tooltip: l10n.cancel,
                              onPressed: () {
                                setState(() => selectedNextActionDate = null);
                              },
                              icon: const Icon(Icons.clear_rounded),
                            ),
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedNextActionDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => selectedNextActionDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: l10n.notes,
                        hintText: l10n.optional,
                        prefixIcon: const Icon(Icons.note_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Checkbox(
                          value: remindForDate && selectedDate != null,
                          onChanged: notificationService.isSupported
                              ? (value) {
                                  setState(() {
                                    remindForDate = value ?? false;
                                  });
                                }
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.remindMe,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                notificationService.isSupported
                                    ? l10n.remindMeDescription
                                    : l10n.reminderNotSupported,
                                style: TextStyle(
                                  color: notificationService.isSupported
                                      ? colors.onSurfaceVariant
                                      : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();

                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.opportunityNameRequired),
                            ),
                          );
                          return;
                        }

                        final url = urlController.text.trim();
                        if (url.isNotEmpty) {
                          final uri = Uri.tryParse(url);
                          if (uri == null ||
                              (uri.scheme != 'http' && uri.scheme != 'https')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.invalidUrl)),
                            );
                            return;
                          }
                        }

                        setState(() => isSaving = true);

                        try {
                          if (isEditing) {
                            await ref
                                .read(opportunityControllerProvider.notifier)
                                .updateOpportunity(
                                  opportunityId: existing!.id,
                                  name: name,
                                  type: selectedType,
                                  status: selectedStatus,
                                  description:
                                      descriptionController.text.trim().isEmpty
                                      ? null
                                      : descriptionController.text.trim(),
                                  organizer:
                                      organizerController.text.trim().isEmpty
                                      ? null
                                      : organizerController.text.trim(),
                                  url: url.isEmpty ? null : url,
                                  deadlineOrEventDate: selectedDate,
                                  eligibility:
                                      eligibilityController.text.trim().isEmpty
                                      ? null
                                      : eligibilityController.text.trim(),
                                  requirements:
                                      requirementsController.text.trim().isEmpty
                                      ? null
                                      : requirementsController.text.trim(),
                                  nextAction:
                                      nextActionController.text.trim().isEmpty
                                      ? null
                                      : nextActionController.text.trim(),
                                  nextActionDueDate: selectedNextActionDate,
                                  notes: notesController.text.trim().isEmpty
                                      ? null
                                      : notesController.text.trim(),
                                );

                            // Cancel old reminders and schedule new ones
                            await notificationService.cancelAllReminders(
                              existing.id,
                            );
                            if (remindForDate && selectedDate != null) {
                              await notificationService.scheduleReminder(
                                opportunityId: existing.id,
                                title: '${l10n.opportunity} - $name',
                                body:
                                    '${l10n.deadlineOrEventDate}: '
                                    '${formatDate(selectedDate!)}',
                                scheduledAt: selectedDate!,
                                typeOffset: 0,
                              );
                            }
                            if (remindForNextAction &&
                                selectedNextActionDate != null) {
                              await notificationService.scheduleReminder(
                                opportunityId: existing.id,
                                title: '$name - ${l10n.nextAction}',
                                body: nextActionController.text.trim(),
                                scheduledAt: selectedNextActionDate!,
                                typeOffset: 1,
                              );
                            }
                          } else {
                            await ref
                                .read(opportunityControllerProvider.notifier)
                                .createOpportunity(
                                  name: name,
                                  type: selectedType,
                                  status: selectedStatus,
                                  description:
                                      descriptionController.text.trim().isEmpty
                                      ? null
                                      : descriptionController.text.trim(),
                                  organizer:
                                      organizerController.text.trim().isEmpty
                                      ? null
                                      : organizerController.text.trim(),
                                  url: url.isEmpty ? null : url,
                                  deadlineOrEventDate: selectedDate,
                                  eligibility:
                                      eligibilityController.text.trim().isEmpty
                                      ? null
                                      : eligibilityController.text.trim(),
                                  requirements:
                                      requirementsController.text.trim().isEmpty
                                      ? null
                                      : requirementsController.text.trim(),
                                  nextAction:
                                      nextActionController.text.trim().isEmpty
                                      ? null
                                      : nextActionController.text.trim(),
                                  nextActionDueDate: selectedNextActionDate,
                                  notes: notesController.text.trim().isEmpty
                                      ? null
                                      : notesController.text.trim(),
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
                              content: Text(
                                l10n.failedToSaveOpportunity(error.toString()),
                              ),
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
                    : Text(isEditing ? l10n.save : l10n.create),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
  descriptionController.dispose();
  organizerController.dispose();
  urlController.dispose();
  eligibilityController.dispose();
  requirementsController.dispose();
  nextActionController.dispose();
  notesController.dispose();
}

String _statusLabel(AppLocalizations l10n, OpportunityStatus status) {
  switch (status) {
    case OpportunityStatus.considering:
      return l10n.considering;
    case OpportunityStatus.preparing:
      return l10n.preparing;
    case OpportunityStatus.applied:
      return l10n.applied;
    case OpportunityStatus.awarded:
      return l10n.awarded;
    case OpportunityStatus.rejected:
      return l10n.rejected;
    case OpportunityStatus.withdrawn:
      return l10n.withdrawn;
    case OpportunityStatus.registered:
      return l10n.registered;
    case OpportunityStatus.attended:
      return l10n.attended;
    case OpportunityStatus.missed:
      return l10n.missed;
    case OpportunityStatus.cancelled:
      return l10n.cancelled;
  }
}
