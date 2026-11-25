import 'package:flutter/material.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../opportunities/domain/entities/opportunity.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _typeIcon(BuildContext context) {
    switch (opportunity.type) {
      case OpportunityType.scholarship:
        return Icons.school_rounded;
      case OpportunityType.event:
        return Icons.calendar_today_rounded;
    }
  }

  Color _typeColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    switch (opportunity.type) {
      case OpportunityType.scholarship:
        return colors.primary;
      case OpportunityType.event:
        return colors.secondary;
    }
  }

  Color _statusColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final terminal = [
      OpportunityStatus.awarded,
      OpportunityStatus.rejected,
      OpportunityStatus.withdrawn,
      OpportunityStatus.attended,
      OpportunityStatus.missed,
      OpportunityStatus.cancelled,
    ];
    if (terminal.contains(opportunity.status)) {
      return colors.onSurfaceVariant;
    }
    if (opportunity.isOverdue) {
      return colors.error;
    }
    switch (opportunity.status) {
      case OpportunityStatus.considering:
        return colors.secondary;
      case OpportunityStatus.preparing:
      case OpportunityStatus.registered:
        return colors.primary;
      case OpportunityStatus.applied:
        return Colors.amber;
      case OpportunityStatus.awarded:
      case OpportunityStatus.attended:
        return Colors.green;
      case OpportunityStatus.rejected:
      case OpportunityStatus.withdrawn:
      case OpportunityStatus.missed:
      case OpportunityStatus.cancelled:
        return colors.error;
    }
  }

  String _dateLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (opportunity.type) {
      case OpportunityType.scholarship:
        return opportunity.deadlineOrEventDate == null
            ? l10n.noDueDate
            : formatDate(opportunity.deadlineOrEventDate!);
      case OpportunityType.event:
        return opportunity.deadlineOrEventDate == null
            ? l10n.noDueDate
            : formatDate(opportunity.deadlineOrEventDate!);
    }
  }

  String _statusLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (opportunity.status) {
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isOverdue = opportunity.isOverdue;

    return Card(
      color: isOverdue ? colors.errorContainer.withOpacity(0.15) : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _typeColor(context).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _typeIcon(context),
                      color: _typeColor(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              opportunity.type == OpportunityType.scholarship
                                  ? l10n.scholarship
                                  : l10n.event,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _typeColor(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _statusColor(context),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n.edit,
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              if (opportunity.description != null &&
                  opportunity.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  opportunity.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: _statusColor(context),
                    ),
                    label: Text(_statusLabel(context)),
                    backgroundColor: _statusColor(context).withOpacity(0.12),
                  ),
                  if (opportunity.deadlineOrEventDate != null)
                    Chip(
                      avatar: const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                      ),
                      label: Text(_dateLabel(context)),
                      backgroundColor: isOverdue
                          ? colors.error.withOpacity(0.12)
                          : null,
                    ),
                  if (opportunity.hasNextAction)
                    Chip(
                      avatar: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(
                        opportunity.nextActionDueDate != null
                            ? '${l10n.nextAction} • ${formatDate(opportunity.nextActionDueDate!)}'
                            : l10n.nextAction,
                      ),
                    ),
                  if (isOverdue)
                    Chip(
                      avatar: const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.amber,
                      ),
                      label: Text(
                        l10n.overdue,
                        style: TextStyle(
                          color: colors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              if (opportunity.nextAction != null &&
                  opportunity.nextAction!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        opportunity.nextAction!,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
