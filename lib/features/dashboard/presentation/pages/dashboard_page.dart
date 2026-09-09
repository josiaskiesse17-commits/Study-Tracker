import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../../core/theme/theme_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final displayName = user?.fullName?.trim();
    final greetingName =
        displayName != null && displayName.isNotEmpty
            ? displayName
            : 'there';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StudyTrack',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              themeModeNotifier.value =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: isDark
                ? 'Switch to light mode'
                : 'Switch to dark mode',
          ),
          IconButton(
            onPressed: () async {
              await ref
                  .read(authControllerProvider.notifier)
                  .logout();
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: colors.onPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Welcome, $greetingName!',
                    style: TextStyle(
                      fontSize: 28,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Keep learning, stay organized, and make progress every day.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section title
            const Text(
              'Your workspace',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Manage your learning from one place.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 18),

            // Courses
            _DashboardCard(
              icon: Icons.school_rounded,
              title: 'Courses',
              description: 'Track your course progress',
              onTap: () {
                context.push('/courses');
              },
            ),

            const SizedBox(height: 14),

            // Tasks
            _DashboardCard(
              icon: Icons.task_alt_rounded,
              title: 'Tasks',
              description: 'Organize what you need to accomplish',
              onTap: () {
                context.push('/tasks');
              },
            ),

            const SizedBox(height: 28),

            // Quick tip
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: colors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stay consistent',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Break your learning goals into small tasks and keep your courses up to date.',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: colors.onPrimaryContainer,
                  size: 27,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

