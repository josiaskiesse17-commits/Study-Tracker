import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';
import 'milestones_page.dart';
import 'project_courses_page.dart';
import 'project_work_page.dart';

class ProjectDetailsPage extends StatelessWidget {
  final Project project;

  const ProjectDetailsPage({
    super.key,
    required this.project,
  });

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'In progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Planning';
    }
  }

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

  String _formatDate(DateTime? date) {
    if (date == null) return 'No deadline';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _statusColor(context, project.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Project Details',
          style: TextStyle(fontWeight: FontWeight.w800),
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
                  _statusLabel(project.status),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (project.description != null &&
                project.description!.trim().isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(
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
                      label: 'Status',
                      value: _statusLabel(project.status),
                    ),

                    const Divider(height: 28),

                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Deadline',
                      value: _formatDate(project.deadline),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Project content',
              style: TextStyle(
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
                title: const Text(
                  'Milestones',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Break this project into smaller goals',
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
                title: const Text(
                  'Work',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Work associated with this project',
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
                title: const Text(
                  'Courses',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Courses associated with this project',
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