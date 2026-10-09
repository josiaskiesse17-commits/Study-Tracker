import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:study_tracker/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:study_tracker/features/courses/data/models/course_model.dart';
import 'package:study_tracker/features/courses/data/repositories/course_repository_impl.dart';

class MockCourseRemoteDataSource extends Mock
    implements CourseRemoteDataSource {}

void main() {
  late MockCourseRemoteDataSource remoteDataSource;
  late CourseRepositoryImpl repository;

  const userId = 'user-123';

  final course = CourseModel(
    id: 'course-1',
    userId: userId,
    name: 'Dart',
    description: 'Learn Dart',
    progress: 50,
    createdAt: DateTime(2026, 9, 1),
  );

  setUp(() {
    remoteDataSource = MockCourseRemoteDataSource();

    repository = CourseRepositoryImpl(remoteDataSource);
  });

  test(
    'getCourses returns courses from remote data source',
    () async {
      when(() => remoteDataSource.getCourses())
          .thenAnswer((_) async => [course]);

      final result = await repository.getCourses();

      expect(result, [course]);

      verify(
        () => remoteDataSource.getCourses(),
      ).called(1);
    },
  );

  test(
    'getCourses returns an empty list when no courses',
    () async {
      when(() => remoteDataSource.getCourses())
          .thenAnswer((_) async => []);

      final result = await repository.getCourses();

      expect(result, isEmpty);

      verify(
        () => remoteDataSource.getCourses(),
      ).called(1);
    },
  );
}
