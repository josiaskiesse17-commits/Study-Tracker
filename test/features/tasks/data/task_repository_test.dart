import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:study_tracker/features/work/data/datasources/task_remote_datasource.dart';
import 'package:study_tracker/features/work/data/models/task_model.dart';
import 'package:study_tracker/features/work/data/repositories/task_repository_impl.dart';

class MockTaskRemoteDataSource extends Mock
    implements TaskRemoteDataSource {}

void main() {
  late MockTaskRemoteDataSource remoteDataSource;
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

    repository = TaskRepositoryImpl(remoteDataSource);
  });

  test(
    'getTasks returns work items from remote data source',
    () async {
      when(() => remoteDataSource.getTasks())
          .thenAnswer((_) async => [workItem]);

      final result = await repository.getTasks();

      expect(result, [workItem]);

      verify(
        () => remoteDataSource.getTasks(),
      ).called(1);
    },
  );

  test(
    'getTasks returns an empty list when no work items',
    () async {
      when(() => remoteDataSource.getTasks())
          .thenAnswer((_) async => []);

      final result = await repository.getTasks();

      expect(result, isEmpty);

      verify(
        () => remoteDataSource.getTasks(),
      ).called(1);
    },
  );
}