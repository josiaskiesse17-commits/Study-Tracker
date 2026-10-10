import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../work/domain/entities/task.dart';
import '../../../work/presentation/providers/task_controller.dart';
import '../../../work/presentation/widgets/work_chip.dart';
import '../../../work/presentation/widgets/work_dialog.dart';
import '../../../work/presentation/widgets/work_labels.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$projectName — ${l10n.work}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showWorkDialog(context, ref, fixedProjectId: projectId);
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addWork),
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
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: colors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.unableToLoadWork,
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
                  child: Text(l10n.tryAgain),
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
                  Center(
                    child: Text(
                      l10n.noWorkYet,
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
                      l10n.addWorkDescription,
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
                    showWorkDialog(
                      context,
                      ref,
                      existing: item,
                      fixedProjectId: projectId,
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
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteWork),
          content: Text(
            l10n.deleteWorkConfirmation(item.title),
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
        .deleteTask(item.id);
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
    final l10n = AppLocalizations.of(context)!;

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
                  tooltip: l10n.edit,
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_rounded,
                  ),
                ),
                IconButton(
                  tooltip: l10n.delete,
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
                WorkChip(
                  label: workTypeLabel(context, item.type),
                  icon: Icons.category_outlined,
                ),
                WorkChip(
                  label: workStatusLabel(context, item.status),
                  icon: Icons.flag_outlined,
                ),
                WorkChip(
                  label: workPriorityLabel(context, item.priority),
                  icon: Icons.priority_high_rounded,
                ),
                if (item.dueDate != null)
                  WorkChip(
                    label: formatDate(item.dueDate!),
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