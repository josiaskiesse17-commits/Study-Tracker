import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_tracker/core/utils/date_format.dart';
import 'package:study_tracker/features/work/presentation/widgets/work_labels.dart';
import 'package:study_tracker/l10n/app_localizations.dart';
import 'package:study_tracker/features/projects/domain/entities/project.dart';
import 'package:study_tracker/features/projects/presentation/pages/milestones_page.dart';
import 'package:study_tracker/features/projects/presentation/pages/project_courses_page.dart';
import 'package:study_tracker/features/projects/presentation/pages/project_work_page.dart';

class ProjectDetailsPage extends ConsumerWidget {
  final Project project;

  const ProjectDetailsPage({
    super.key,
    required this.project,
  });

  Color _statusColor(BuildContext context, String status) {
    final colors = Theme.of(context).colorScheme;

    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return colors.primary;
      default:
        return colors.secondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _statusColor(context, project.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.projectDetails,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: Icon(
                  Icons.circle,
                  size: 10,
                  color: statusColor,
                ),
                label: Text(
                  projectStatusLabel(context, project.status),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (project.description != null &&
                project.description!.trim().isNotEmpty) ...[
              Text(
                l10n.description,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                project.description!,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 28),
            ],

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.flag_rounded,
                      label: l10n.status,
                      value: projectStatusLabel(context, project.status),
                    ),

                    const Divider(height: 28),

                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: l10n.dueDate,
                      value: project.deadline == null
                          ? l10n.noDeadline
                          : formatDate(project.deadline!),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              l10n.projectContent,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            // MILESTONES
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.flag_circle_rounded,
                ),
                title: Text(
                  l10n.milestones,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  l10n.workAssociated,
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MilestonesPage(
                        projectId: project.id,
                        projectName: project.name,
                      ),
                    ),
                  );
                },
              ),
            ),

            // WORK
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.task_alt_rounded,
                ),
                title: Text(
                  l10n.work,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  l10n.workAssociated,
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectWorkPage(
                        projectId: project.id,
                        projectName: project.name,
                      ),
                    ),
                  );
                },
              ),
            ),

            // COURSES
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.school_rounded,
                ),
                title: Text(
                  l10n.coursesAssociated,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  l10n.coursesAssociated,
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectCoursesPage(
                        projectId: project.id,
                        projectName: project.name,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}