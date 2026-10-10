import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/task_controller.dart';
import '../widgets/work_chip.dart';
import '../widgets/work_dialog.dart';
import '../widgets/work_labels.dart';

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
              onPressed: () => showWorkDialog(context, ref),
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
        error: (error, stackTrace) => ErrorState(
          message: l10n.unableToLoadWork,
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
                        showWorkDialog(context, ref);
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
                                    showWorkDialog(
                                      context,
                                      ref,
                                      existing: item,
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
}