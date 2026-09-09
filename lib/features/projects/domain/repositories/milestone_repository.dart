import '../entities/milestone.dart';

abstract class MilestoneRepository {
  Future<List<Milestone>> getMilestones(
    String projectId,
  );

  Future<List<Milestone>> getCachedMilestones(
    String projectId,
  );

  Future<Milestone> createMilestone({
    required String projectId,
    required String title,
    String? description,
    String status = 'pending',
    DateTime? dueDate,
  });

  Future<void> updateMilestone({
    required String milestoneId,
    required String projectId,
    required String title,
    String? description,
    required String status,
    DateTime? dueDate,
  });

  Future<void> deleteMilestone(
    String milestoneId,
  );
}