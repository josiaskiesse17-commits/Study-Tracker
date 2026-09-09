import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:study_tracker/core/storage/app_database.dart';
import 'package:study_tracker/features/courses/data/datasources/course_local_datasource.dart';
import 'package:study_tracker/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:study_tracker/features/courses/data/models/course_model.dart';
import 'package:study_tracker/features/courses/data/repositories/course_repository_impl.dart';

class MockCourseRemoteDataSource extends Mock
    implements CourseRemoteDataSource {}

class MockCourseLocalDataSource extends Mock
    implements CourseLocalDataSource {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockCourseRemoteDataSource remoteDataSource;
  late MockCourseLocalDataSource localDataSource;
  late MockAppDatabase database;
  late MockSupabaseClient supabase;
  late MockGoTrueClient auth;
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
    localDataSource = MockCourseLocalDataSource();
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

    repository = CourseRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      database: database,
      supabase: supabase,
    );
  });

  test(
    'getCachedCourses returns cached courses',
    () async {
      when(() => localDataSource.getCourses(userId))
          .thenAnswer((_) async => [course]);

      final result = await repository.getCachedCourses();

      expect(result, [course]);

      verify(
        () => localDataSource.getCourses(userId),
      ).called(1);
    },
  );

  test(
    'getCachedCourses returns an empty list when cache is empty',
    () async {
      when(() => localDataSource.getCourses(userId))
          .thenAnswer((_) async => []);

      final result = await repository.getCachedCourses();

      expect(result, isEmpty);

      verify(
        () => localDataSource.getCourses(userId),
      ).called(1);
    },
  );
}
