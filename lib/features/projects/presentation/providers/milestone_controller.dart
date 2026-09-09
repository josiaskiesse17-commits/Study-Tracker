import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/milestone.dart';
import '../../domain/repositories/milestone_repository.dart';
import 'milestone_provider.dart';

final milestoneControllerProvider =
    AsyncNotifierProvider<MilestoneController, List<Milestone>>(
  MilestoneController.new,
);

class MilestoneController extends AsyncNotifier<List<Milestone>> {
  late final MilestoneRepository _repository;

  @override
  Future<List<Milestone>> build() async {
    _repository = ref.read(milestoneRepositoryProvider);
    return [];
  }

  Future<void> loadMilestones(String projectId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _repository.getMilestones(projectId),
    );
  }

  Future<void> refreshMilestones(String projectId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _repository.getMilestones(projectId),
    );
  }

  Future<void> createMilestone({
    required String projectId,
    required String title,
    String? description,
    String status = 'pending',
    DateTime? dueDate,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.createMilestone(
        projectId: projectId,
        title: title,
        description: description,
        status: status,
        dueDate: dueDate,
      );

      return _repository.getMilestones(projectId);
    });
  }

  Future<void> updateMilestone({
    required String milestoneId,
    required String projectId,
    required String title,
    String? description,
    required String status,
    DateTime? dueDate,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.updateMilestone(
        milestoneId: milestoneId,
        projectId: projectId,
        title: title,
        description: description,
        status: status,
        dueDate: dueDate,
      );

      return _repository.getMilestones(projectId);
    });
  }

  Future<void> deleteMilestone({
    required String milestoneId,
    required String projectId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.deleteMilestone(milestoneId);

      return _repository.getMilestones(projectId);
    });
  }
}