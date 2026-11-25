import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/error_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services/notification_service.dart';
import '../../domain/entities/opportunity.dart';
import '../providers/opportunity_controller.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/opportunity_dialog.dart';

class OpportunitiesPage extends ConsumerStatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  ConsumerState<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends ConsumerState<OpportunitiesPage> {
  String _filter = 'all'; // 'all', 'scholarship', 'event'

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final opportunitiesAsync = ref.watch(opportunityControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.opportunities,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.filterAll,
            initialValue: _filter,
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text(l10n.filterAll)),
              PopupMenuItem(
                value: 'scholarship',
                child: Text(l10n.filterScholarships),
              ),
              PopupMenuItem(value: 'event', child: Text(l10n.filterEvents)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(
            filter: _filter,
            onChanged: (value) {
              setState(() {
                _filter = value;
              });
            },
            l10n: l10n,
          ),
          Expanded(
            child: opportunitiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => ErrorState(
                message: l10n.unableToLoadOpportunities,
                error: error.toString(),
                onRetry: () {
                  ref
                      .read(opportunityControllerProvider.notifier)
                      .refreshOpportunities();
                },
              ),
              data: (opportunities) {
                final filtered = _filterOpportunities(opportunities);
                final sorted = _sortOpportunities(filtered);

                if (sorted.isEmpty) {
                  return _EmptyOpportunities(
                    filter: _filter,
                    onAdd: () {
                      showOpportunityDialog(context: context, ref: ref);
                    },
                    l10n: l10n,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () {
                    return ref
                        .read(opportunityControllerProvider.notifier)
                        .refreshOpportunities();
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final opportunity = sorted[index];
                      return OpportunityCard(
                        opportunity: opportunity,
                        onTap: () {
                          showOpportunityDialog(
                            context: context,
                            ref: ref,
                            existing: opportunity,
                          );
                        },
                        onEdit: () {
                          showOpportunityDialog(
                            context: context,
                            ref: ref,
                            existing: opportunity,
                          );
                        },
                        onDelete: () {
                          _confirmDelete(context, ref, opportunity);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showOpportunityDialog(context: context, ref: ref);
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.createOpportunity),
      ),
    );
  }

  List<Opportunity> _filterOpportunities(List<Opportunity> opportunities) {
    switch (_filter) {
      case 'scholarship':
        return opportunities
            .where((o) => o.type == OpportunityType.scholarship)
            .toList();
      case 'event':
        return opportunities
            .where((o) => o.type == OpportunityType.event)
            .toList();
      default:
        return opportunities;
    }
  }

  List<Opportunity> _sortOpportunities(List<Opportunity> opportunities) {
    final sorted = List<Opportunity>.from(opportunities);
    sorted.sort((a, b) {
      final aDate = a.relevantDate;
      final bDate = b.relevantDate;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return 1;
      return aDate.compareTo(bDate);
    });
    return sorted;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Opportunity opportunity,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteOpportunity),
          content: Text(l10n.deleteOpportunityConfirmation(opportunity.name)),
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

    try {
      // Cancel all notifications for this opportunity before deleting
      await ref
          .read(notificationServiceProvider)
          .cancelAllReminders(opportunity.id);

      await ref
          .read(opportunityControllerProvider.notifier)
          .deleteOpportunity(opportunity.id);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToDeleteOpportunity(error.toString())),
        ),
      );
    }
  }
}

class _FilterChips extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onChanged;
  final AppLocalizations l10n;

  const _FilterChips({
    required this.filter,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              l10n.filterAll,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
          ),
          _FilterChip(
            label: l10n.filterAll,
            value: 'all',
            groupValue: filter,
            onChanged: onChanged,
            colors: colors,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.filterScholarships,
            value: 'scholarship',
            groupValue: filter,
            onChanged: onChanged,
            colors: colors,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.filterEvents,
            value: 'event',
            groupValue: filter,
            onChanged: onChanged,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;
  final ColorScheme colors;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onChanged(value);
        }
      },
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
      backgroundColor: colors.surfaceContainerHighest,
      selectedColor: colors.primary,
      checkmarkColor: colors.onPrimary,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _EmptyOpportunities extends StatelessWidget {
  final String filter;
  final VoidCallback onAdd;
  final AppLocalizations l10n;

  const _EmptyOpportunities({
    required this.filter,
    required this.onAdd,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter == 'scholarship'
                  ? Icons.school_outlined
                  : filter == 'event'
                  ? Icons.event_outlined
                  : Icons.card_travel_outlined,
              size: 64,
              color: colors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noOpportunitiesYet,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createOpportunityDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.createOpportunity),
            ),
          ],
        ),
      ),
    );
  }
}
