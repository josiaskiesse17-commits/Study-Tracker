import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/linked_course_remote_datasource.dart';
import '../../data/repositories/linked_course_repository_impl.dart';
import '../../domain/repositories/linked_course_repository.dart';

final linkedCourseRemoteDataSourceProvider =
    Provider<LinkedCourseRemoteDataSource>((ref) {
  return LinkedCourseRemoteDataSource();
});

final linkedCourseRepositoryProvider =
    Provider<LinkedCourseRepository>((ref) {
  return LinkedCourseRepositoryImpl(
    ref.read(linkedCourseRemoteDataSourceProvider),
  );
});