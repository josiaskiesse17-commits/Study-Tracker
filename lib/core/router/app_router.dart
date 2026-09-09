import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

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
        builder: (context, state) {
          return const LoginPage();
        },
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) {
          return const RegisterPage();
        },
      ),

      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          return const DashboardPage();
        },
      ),

      GoRoute(
        path: '/courses',
        builder: (context, state) {
          return const CoursesPage();
        },
      ),

      GoRoute(
        path: '/tasks',
        builder: (context, state) {
          return const TasksPage();
        },
      ),
    ],
  );
});