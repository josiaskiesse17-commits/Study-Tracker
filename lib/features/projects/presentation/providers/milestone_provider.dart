import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/milestone_remote_datasource.dart';
import '../../data/repositories/milestone_repository_impl.dart';
import '../../domain/repositories/milestone_repository.dart';

final milestoneRemoteDataSourceProvider =
    Provider<MilestoneRemoteDataSource>((ref) {
  return MilestoneRemoteDataSource();
});

final milestoneRepositoryProvider =
    Provider<MilestoneRepository>((ref) {
  return MilestoneRepositoryImpl(
    ref.read(milestoneRemoteDataSourceProvider),
  );
});