import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/app_database.dart';
import '../../data/datasources/project_local_datasource.dart';
import '../../data/datasources/project_remote_datasource.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/repositories/project_repository.dart';

final projectDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final projectConnectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final projectRemoteDataSourceProvider =
    Provider<ProjectRemoteDataSource>((ref) {
  return ProjectRemoteDataSource(
    ref.read(dioProvider),
  );
});

final projectLocalDataSourceProvider =
    Provider<ProjectLocalDataSource>((ref) {
  return ProjectLocalDataSource(
    ref.read(projectDatabaseProvider),
  );
});

final projectRepositoryProvider =
    Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    remoteDataSource: ref.read(
      projectRemoteDataSourceProvider,
    ),
    localDataSource: ref.read(
      projectLocalDataSourceProvider,
    ),
    connectivity: ref.read(
      projectConnectivityProvider,
    ),
    supabase: Supabase.instance.client,
  );
});