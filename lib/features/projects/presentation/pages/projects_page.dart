import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/project.dart';
import '../providers/project_controller.dart';
import 'project_details_page.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.projects,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: projectsState.when(
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
                Text(
                  l10n.unableToLoadProjects,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(projectControllerProvider.notifier)
                        .refreshProjects();
                  },
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (projects) {
          if (projects.isEmpty) {
            return _EmptyProjects(
              onAddProject: () {
                _showProjectDialog(context, ref);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(projectControllerProvider.notifier)
                  .refreshProjects();
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                100,
              ),
              itemCount: projects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final project = projects[index];

                return _ProjectCard(
                  project: project,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailsPage(
                          project: project,
                        ),
                      ),
                    );
                  },
                  onEdit: () {
                    _showProjectDialog(
                      context,
                      ref,
                      project: project,
                    );
                  },
                  onDelete: () {
                    _confirmDelete(
                      context,
                      ref,
                      project,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showProjectDialog(context, ref);
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addProject),
      ),
    );
  }

  Future<void> _showProjectDialog(
    BuildContext context,
    WidgetRef ref, {
    Project? project,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    final nameController = TextEditingController(
      text: project?.name ?? '',
    );

    final descriptionController = TextEditingController(
      text: project?.description ?? '',
    );

    String status = project?.status ?? 'planning';
    DateTime? deadline = project?.deadline;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final screenHeight = MediaQuery.sizeOf(context).height;

            return AlertDialog(
              title: Text(
                project == null
                    ? l10n.createProject
                    : l10n.editProject,
              ),
              content: SizedBox(
                height: screenHeight * 0.55,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: l10n.name,
                          hintText: l10n.projectName,
                        ),
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: l10n.description,
                          hintText: l10n.optionalDescription,
                        ),
                        onSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: InputDecoration(
                          labelText: l10n.status,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'planning',
                            child: Text(l10n.planning),
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
                              status = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.calendar_today_rounded,
                        ),
                        title: Text(l10n.dueDate),
                        subtitle: Text(
                          deadline == null
                              ? l10n.noDeadline
                              : _formatDate(deadline!),
                        ),
                        trailing: deadline == null
                            ? const Icon(
                                Icons.chevron_right_rounded,
                              )
                            : IconButton(
                                tooltip: l10n.clearDeadline,
                                onPressed: () {
                                  setState(() {
                                    deadline = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.clear_rounded,
                                ),
                              ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                deadline ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setState(() {
                              deadline = picked;
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
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.projectNameRequired,
                          ),
                        ),
                      );
                      return;
                    }

                    final description =
                        descriptionController.text.trim();

                    final controller = ref.read(
                      projectControllerProvider.notifier,
                    );

                    if (project == null) {
                      await controller.createProject(
                        name: name,
                        description: description.isEmpty
                            ? null
                            : description,
                        status: status,
                        deadline: deadline,
                      );
                    } else {
                      await controller.updateProject(
                        projectId: project.id,
                        name: name,
                        description: description.isEmpty
                            ? null
                            : description,
                        status: status,
                        deadline: deadline,
                      );
                    }

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text(
                    project == null ? l10n.create : l10n.save,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteProject),
          content: Text(
            l10n.permanentlyDeleteProject(project.name),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
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
        .read(projectControllerProvider.notifier)
        .deleteProject(project.id);
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _EmptyProjects extends StatelessWidget {
  final VoidCallback onAddProject;

  const _EmptyProjects({
    required this.onAddProject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: colors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noProjectsYet,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createProjectDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddProject,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.createProject),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: colors.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: l10n.projectActions,
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(l10n.edit),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                ],
              ),
              if (project.description != null &&
                  project.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  project.description!,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(status: project.status),
                  if (project.deadline != null)
                    Chip(
                      avatar: const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                      ),
                      label: Text(
                        _formatDate(project.deadline!),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final label = switch (status) {
      'planning' => l10n.planning,
      'in_progress' => l10n.inProgress,
      'completed' => l10n.completed,
      _ => status,
    };

    return Chip(
      avatar: Icon(
        status == 'completed'
            ? Icons.check_circle_rounded
            : Icons.pending_rounded,
        size: 17,
      ),
      label: Text(label),
      backgroundColor: colors.primaryContainer,
    );
  }
}
