import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_tracker/features/auth/domain/entities/user.dart';
import 'package:study_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:study_tracker/features/work/domain/entities/task.dart';
import 'package:study_tracker/features/work/domain/repositories/task_repository.dart';
import 'package:study_tracker/features/work/presentation/providers/task_provider.dart';
import 'package:study_tracker/features/work/presentation/widgets/work_dialog.dart';
import 'package:study_tracker/l10n/app_localizations.dart';

class FakeTaskRepository implements TaskRepository {
  final List<WorkItem> _tasks = [];

  @override
  Future<List<WorkItem>> getTasks() async => List.from(_tasks);

  @override
  Future<WorkItem> createTask({
    required String title,
    String? description,
    String? courseId,
    String? projectId,
    String type = 'other',
    String status = 'pending',
    String priority = 'medium',
    DateTime? dueDate,
  }) async {
    final task = WorkItem(
      id: 'new-${_tasks.length + 1}',
      userId: 'user-1',
      title: title,
      description: description,
      courseId: courseId,
      projectId: projectId,
      type: type,
      status: status,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<void> updateTask({
    required String taskId,
    required String title,
    String? description,
    String? courseId,
    String? projectId,
    required String type,
    required String status,
    required String priority,
    DateTime? dueDate,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = WorkItem(
        id: _tasks[index].id,
        userId: _tasks[index].userId,
        courseId: courseId,
        projectId: projectId,
        title: title,
        description: description,
        type: type,
        status: status,
        priority: priority,
        dueDate: dueDate,
        createdAt: _tasks[index].createdAt,
      );
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
  }
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<User> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    throw UnimplementedError();
  }

  @override
  User? getCurrentUser() => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('showWorkDialog', () {
    late FakeTaskRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeTaskRepository();
    });

Widget makeTestButton({
    required Future<void> Function(BuildContext, WidgetRef) onPressed,
  }) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, _) => ElevatedButton(
          onPressed: () => onPressed(context, ref),
          child: const Text('Open'),
        ),
      ),
    );
  }

  testWidgets('create mode: empty title shows snackbar, does not call createTask',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => fakeRepo),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: makeTestButton(
            onPressed: (context, ref) => showWorkDialog(context, ref),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Create work'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    expect(find.text('Title is required.'), findsOneWidget);
    expect(fakeRepo._tasks, isEmpty);
  });

  testWidgets('edit mode: shows existing title and description', (tester) async {
    final existingTask = WorkItem(
      id: 'task-1',
      userId: 'user-1',
      title: 'Existing Title',
      description: 'Existing Description',
      courseId: 'course-1',
      projectId: 'project-1',
      type: 'homework',
      status: 'pending',
      priority: 'high',
      dueDate: DateTime(2026, 9, 15),
      createdAt: DateTime(2026, 9, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => fakeRepo),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: makeTestButton(
            onPressed: (context, ref) => showWorkDialog(
              context,
              ref,
              existing: existingTask,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Edit work'), findsOneWidget);
    expect(find.text('Existing Title'), findsOneWidget);
    expect(find.text('Existing Description'), findsOneWidget);
    expect(find.text('Homework'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('High priority'), findsOneWidget);
  });

  testWidgets('create mode: valid title calls createTask with fixedProjectId',
      (tester) async {
    const fixedProjectId = 'project-fixed';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) => fakeRepo),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: makeTestButton(
            onPressed: (context, ref) => showWorkDialog(
              context,
              ref,
              fixedProjectId: fixedProjectId,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'New Task Title');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    expect(fakeRepo._tasks, hasLength(1));
    final created = fakeRepo._tasks.first;
    expect(created.title, 'New Task Title');
    expect(created.projectId, fixedProjectId);
    expect(created.courseId, null);
  });
  });
}