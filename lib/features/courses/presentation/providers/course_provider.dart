import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/app_database.dart';
import '../../data/datasources/course_local_datasource.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/repositories/course_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final courseRemoteDataSourceProvider =
    Provider<CourseRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);

  return CourseRemoteDataSource(dio);
});

final courseLocalDataSourceProvider =
    Provider<CourseLocalDataSource>((ref) {
  return CourseLocalDataSource(
    ref.read(appDatabaseProvider),
  );
});

final courseRepositoryProvider =
    Provider<CourseRepository>((ref) {
  return CourseRepositoryImpl(
    remoteDataSource: ref.read(
      courseRemoteDataSourceProvider,
    ),
    localDataSource: ref.read(
      courseLocalDataSourceProvider,
    ),
    database: ref.read(
      appDatabaseProvider,
    ),
    supabase: Supabase.instance.client,
  );
});