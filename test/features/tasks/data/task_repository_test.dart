import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:study_tracker/core/storage/app_database.dart';
import 'package:study_tracker/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:study_tracker/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:study_tracker/features/tasks/data/models/task_model.dart';
import 'package:study_tracker/features/tasks/data/repositories/task_repository_impl.dart';

class MockTaskRemoteDataSource extends Mock
    implements TaskRemoteDataSource {}

class MockTaskLocalDataSource extends Mock
    implements TaskLocalDataSource {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTaskRemoteDataSource remoteDataSource;
  late MockTaskLocalDataSource localDataSource;
  late MockAppDatabase database;
  late MockSupabaseClient supabase;
  late MockGoTrueClient auth;
  late TaskRepositoryImpl repository;

  const userId = 'user-123';

  final task = TaskModel(
    id: 'task-1',
    userId: userId,
    courseId: 'course-1',
    title: 'Finish Dart exercise',
    description: 'Complete the exercise',
    completed: false,
    createdAt: DateTime(2026, 9, 1),
  );

  setUp(() {
    remoteDataSource = MockTaskRemoteDataSource();
    localDataSource = MockTaskLocalDataSource();
    database = MockAppDatabase();
    supabase = MockSupabaseClient();
    auth = MockGoTrueClient();

    when(() => supabase.auth).thenReturn(auth);

    when(() => auth.currentUser).thenReturn(
      User(
        id: userId,
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    repository = TaskRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      database: database,
      supabase: supabase,
    );
  });

  test(
    'getCachedTasks returns tasks from local datasource',
    () async {
      when(() => localDataSource.getTasks(userId))
          .thenAnswer((_) async => [task]);

      final result = await repository.getCachedTasks();

      expect(result, [task]);

      verify(
        () => localDataSource.getTasks(userId),
      ).called(1);
    },
  );
}
