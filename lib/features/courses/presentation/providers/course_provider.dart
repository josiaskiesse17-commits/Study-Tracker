import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/course_remote_datasource.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/repositories/course_repository.dart';

final courseRemoteDataSourceProvider =
    Provider<CourseRemoteDataSource>((ref) {
  return CourseRemoteDataSource();
});

final courseRepositoryProvider =
    Provider<CourseRepository>((ref) {
  return CourseRepositoryImpl(
    ref.read(courseRemoteDataSourceProvider),
  );
});