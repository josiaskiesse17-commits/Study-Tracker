import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/projects/presentation/pages/project_details_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/work/presentation/pages/tasks_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthStateListenable(FirebaseAuth.instance);
  ref.onDispose(authListenable.dispose);

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authListenable,

    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;

      final isAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthPage) {
        return '/login';
      }

      if (isLoggedIn && isAuthPage) {
        return '/dashboard';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      GoRoute(
        path: '/courses',
        builder: (context, state) => const CoursesPage(),
      ),

      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TasksPage(),
      ),

      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsPage(),
      ),

      GoRoute(
        path: '/projects/:id',
        builder: (context, state) {
          final project = state.extra as Project;

          return ProjectDetailsPage(
            project: project,
          );
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(FirebaseAuth auth) {
    _subscription = auth.authStateChanges().listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}