import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:study_tracker/features/work/data/datasources/task_local_datasource.dart';
import 'package:study_tracker/features/work/data/datasources/task_remote_datasource.dart';
import 'package:study_tracker/features/work/data/models/task_model.dart';
import 'package:study_tracker/features/work/data/repositories/task_repository_impl.dart';

class MockTaskRemoteDataSource extends Mock
    implements TaskRemoteDataSource {}

class MockTaskLocalDataSource extends Mock
    implements TaskLocalDataSource {}

class MockConnectivity extends Mock implements Connectivity {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTaskRemoteDataSource remoteDataSource;
  late MockTaskLocalDataSource localDataSource;
  late MockConnectivity connectivity;
  late MockSupabaseClient supabase;
  late MockGoTrueClient auth;
  late TaskRepositoryImpl repository;

  const userId = 'user-123';

  final workItem = TaskModel(
    id: 'task-1',
    userId: userId,
    courseId: 'course-1',
    projectId: null,
    title: 'Finish Dart exercise',
    description: 'Complete the exercise',
    type: 'exercise',
    status: 'pending',
    priority: 'medium',
    dueDate: DateTime(2026, 9, 10),
    createdAt: DateTime(2026, 9, 1),
  );

  setUp(() {
    remoteDataSource = MockTaskRemoteDataSource();
    localDataSource = MockTaskLocalDataSource();
    connectivity = MockConnectivity();
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
      connectivity: connectivity,
      supabase: supabase,
    );
  });

  test(
    'getCachedTasks returns work items from local datasource',
    () async {
      when(() => localDataSource.getTasks(userId))
          .thenAnswer((_) async => [workItem]);

      final result = await repository.getCachedTasks();

      expect(result, [workItem]);

      verify(
        () => localDataSource.getTasks(userId),
      ).called(1);
    },
  );
}