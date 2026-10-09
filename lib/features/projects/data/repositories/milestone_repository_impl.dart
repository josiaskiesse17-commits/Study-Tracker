import '../../domain/entities/milestone.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../datasources/milestone_remote_datasource.dart';

class MilestoneRepositoryImpl implements MilestoneRepository {
  final MilestoneRemoteDataSource remoteDataSource;

  MilestoneRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Milestone>> getMilestones(
    String projectId,
  ) async {
    return remoteDataSource.getMilestones(projectId);
  }

  @override
  Future<Milestone> createMilestone({
    required String projectId,
    required String title,
    String? description,
    String status = 'pending',
    DateTime? dueDate,
  }) async {
    return remoteDataSource.createMilestone(
      projectId: projectId,
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
    );
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
    await remoteDataSource.updateMilestone(
      milestoneId: milestoneId,
      projectId: projectId,
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
    );
  }

  @override
  Future<void> deleteMilestone({
    required String milestoneId,
    required String projectId,
  }) async {
    await remoteDataSource.deleteMilestone(
      milestoneId: milestoneId,
      projectId: projectId,
    );
  }
}