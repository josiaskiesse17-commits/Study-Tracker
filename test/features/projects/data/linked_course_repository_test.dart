import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:study_tracker/features/projects/data/datasources/linked_course_remote_datasource.dart';
import 'package:study_tracker/features/projects/data/models/linked_course_model.dart';
import 'package:study_tracker/features/projects/data/repositories/linked_course_repository_impl.dart';

class MockLinkedCourseRemoteDataSource extends Mock
    implements LinkedCourseRemoteDataSource {}

void main() {
  late MockLinkedCourseRemoteDataSource remoteDataSource;
  late LinkedCourseRepositoryImpl repository;

  const projectId = 'project-1';

  setUp(() {
    remoteDataSource = MockLinkedCourseRemoteDataSource();

    repository = LinkedCourseRepositoryImpl(remoteDataSource);
  });

  test(
    'getLinkedCourseIds returns course ids from remote data source',
    () async {
      final linkedCourses = [
        LinkedCourseModel(courseId: 'course-1', linkedAt: DateTime(2026, 9, 1)),
        LinkedCourseModel(courseId: 'course-2', linkedAt: DateTime(2026, 9, 2)),
      ];

      when(() => remoteDataSource.getLinkedCourses(projectId))
          .thenAnswer((_) async => linkedCourses);

      final result = await repository.getLinkedCourseIds(projectId);

      expect(result, {'course-1', 'course-2'});

      verify(
        () => remoteDataSource.getLinkedCourses(projectId),
      ).called(1);
    },
  );

  test(
    'getLinkedCourseIds returns an empty set when no linked courses',
    () async {
      when(() => remoteDataSource.getLinkedCourses(projectId))
          .thenAnswer((_) async => []);

      final result = await repository.getLinkedCourseIds(projectId);

      expect(result, isEmpty);

      verify(
        () => remoteDataSource.getLinkedCourses(projectId),
      ).called(1);
    },
  );

  test(
    'linkCourse calls remote data source',
    () async {
      when(() => remoteDataSource.linkCourse(projectId, 'course-3'))
          .thenAnswer((_) async {});

      await repository.linkCourse(projectId, 'course-3');

      verify(
        () => remoteDataSource.linkCourse(projectId, 'course-3'),
      ).called(1);
    },
  );

  test(
    'unlinkCourse calls remote data source',
    () async {
      when(() => remoteDataSource.unlinkCourse(projectId, 'course-1'))
          .thenAnswer((_) async {});

      await repository.unlinkCourse(projectId, 'course-1');

      verify(
        () => remoteDataSource.unlinkCourse(projectId, 'course-1'),
      ).called(1);
    },
  );
}