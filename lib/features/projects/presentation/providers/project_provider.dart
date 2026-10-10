import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/project_remote_datasource.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/repositories/project_repository.dart';

final projectRemoteDataSourceProvider =
    Provider<ProjectRemoteDataSource>((ref) {
  return ProjectRemoteDataSource();
});

final projectRepositoryProvider =
    Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    ref.read(projectRemoteDataSourceProvider),
  );
});