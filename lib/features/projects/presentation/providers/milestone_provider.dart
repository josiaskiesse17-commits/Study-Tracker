import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/app_database.dart';
import '../../data/datasources/milestone_local_datasource.dart';
import '../../data/datasources/milestone_remote_datasource.dart';
import '../../data/repositories/milestone_repository_impl.dart';
import '../../domain/repositories/milestone_repository.dart';

final milestoneDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final milestoneConnectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final milestoneRemoteDataSourceProvider =
    Provider<MilestoneRemoteDataSource>((ref) {
  return MilestoneRemoteDataSource(
    ref.read(dioProvider),
  );
});

final milestoneLocalDataSourceProvider =
    Provider<MilestoneLocalDataSource>((ref) {
  return MilestoneLocalDataSource(
    ref.read(milestoneDatabaseProvider),
  );
});

final milestoneRepositoryProvider =
    Provider<MilestoneRepository>((ref) {
  return MilestoneRepositoryImpl(
    remoteDataSource: ref.read(
      milestoneRemoteDataSourceProvider,
    ),
    localDataSource: ref.read(
      milestoneLocalDataSourceProvider,
    ),
    connectivity: ref.read(
      milestoneConnectivityProvider,
    ),
    supabase: Supabase.instance.client,
  );
});