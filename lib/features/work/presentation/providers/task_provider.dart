import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';

final taskRemoteDataSourceProvider =
    Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource();
});

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    ref.read(taskRemoteDataSourceProvider),
  );
});