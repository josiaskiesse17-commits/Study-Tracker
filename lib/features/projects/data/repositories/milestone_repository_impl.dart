import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../datasources/milestone_local_datasource.dart';
import '../datasources/milestone_remote_datasource.dart';
import '../models/milestone_model.dart';

class MilestoneRepositoryImpl implements MilestoneRepository {
  final MilestoneRemoteDataSource remoteDataSource;
  final MilestoneLocalDataSource localDataSource;
  final Connectivity connectivity;
  final SupabaseClient supabase;

  MilestoneRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
    required this.supabase,
  });

  @override
  Future<List<Milestone>> getMilestones(
    String projectId,
  ) async {
    final connectivityResult = await connectivity.checkConnectivity();

    final isOnline =
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.ethernet);

    if (isOnline) {
      try {
        final milestones =
            await remoteDataSource.getMilestones(projectId);

        await localDataSource.saveMilestones(milestones);

        return milestones;
      } on NetworkException {
        return localDataSource.getMilestones(projectId);
      }
    }

    return localDataSource.getMilestones(projectId);
  }

  @override
  Future<List<Milestone>> getCachedMilestones(
    String projectId,
  ) {
    return localDataSource.getMilestones(projectId);
  }

  @override
  Future<Milestone> createMilestone({
    required String projectId,
    required String title,
    String? description,
    String status = 'pending',
    DateTime? dueDate,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw const NetworkException(
        'You must be signed in to create a milestone.',
      );
    }

    final connectivityResult = await connectivity.checkConnectivity();

    final isOnline =
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.ethernet);

    if (!isOnline) {
      throw const NetworkException(
        'An internet connection is required to create a milestone.',
      );
    }

    final milestone =
        await remoteDataSource.createMilestone(
      projectId: projectId,
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
    );

    await localDataSource.saveMilestone(milestone);

    return milestone;
  }

  @override
  Future<void> updateMilestone({
    required String milestoneId,
    required String projectId,
    required String title,
    String? description,
    required String status,
    DateTime? dueDate,
  }) async {
    final connectivityResult = await connectivity.checkConnectivity();

    final isOnline =
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.ethernet);

    if (!isOnline) {
      throw const NetworkException(
        'An internet connection is required to update a milestone.',
      );
    }

    await remoteDataSource.updateMilestone(
      milestoneId: milestoneId,
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
    );

    final cachedMilestones =
        await localDataSource.getMilestones(projectId);

    final existing = cachedMilestones.firstWhere(
      (milestone) => milestone.id == milestoneId,
    );

    final updated = MilestoneModel(
      id: existing.id,
      projectId: existing.projectId,
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
      createdAt: existing.createdAt,
    );

    await localDataSource.updateMilestone(updated);
  }

  @override
  Future<void> deleteMilestone(
    String milestoneId,
  ) async {
    final connectivityResult = await connectivity.checkConnectivity();

    final isOnline =
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.ethernet);

    if (!isOnline) {
      throw const NetworkException(
        'An internet connection is required to delete a milestone.',
      );
    }

    await remoteDataSource.deleteMilestone(milestoneId);

    await localDataSource.deleteMilestone(milestoneId);
  }
}