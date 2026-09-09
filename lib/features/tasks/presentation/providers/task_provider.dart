import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/app_database.dart';
import '../../data/datasources/task_local_datasource.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';

final taskDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final taskRemoteDataSourceProvider =
    Provider<TaskRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);

  return TaskRemoteDataSource(dio);
});

final taskLocalDataSourceProvider =
    Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSource(
    ref.read(taskDatabaseProvider),
  );
});

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    remoteDataSource: ref.read(
      taskRemoteDataSourceProvider,
    ),
    localDataSource: ref.read(
      taskLocalDataSourceProvider,
    ),
    database: ref.read(
      taskDatabaseProvider,
    ),
    supabase: Supabase.instance.client,
  );
});