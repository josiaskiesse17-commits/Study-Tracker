import '../../domain/entities/opportunity.dart';
import '../../domain/repositories/opportunity_repository.dart';
import '../datasources/opportunity_remote_datasource.dart';

class OpportunityRepositoryImpl implements OpportunityRepository {
  final OpportunityRemoteDataSource remoteDataSource;

  OpportunityRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Opportunity>> getOpportunities() async {
    return remoteDataSource.getOpportunities();
  }

  @override
  Future<Opportunity> createOpportunity({
    required String name,
    required OpportunityType type,
    required OpportunityStatus status,
    String? description,
    String? organizer,
    String? url,
    DateTime? deadlineOrEventDate,
    String? eligibility,
    String? requirements,
    String? nextAction,
    DateTime? nextActionDueDate,
    String? notes,
  }) async {
    return remoteDataSource.createOpportunity(
      name: name,
      type: type.name,
      status: status.name,
      description: description,
      organizer: organizer,
      url: url,
      deadlineOrEventDate: deadlineOrEventDate,
      eligibility: eligibility,
      requirements: requirements,
      nextAction: nextAction,
      nextActionDueDate: nextActionDueDate,
      notes: notes,
    );
  }

  @override
  Future<void> updateOpportunity({
    required String opportunityId,
    required String name,
    required OpportunityType type,
    String? description,
    String? organizer,
    String? url,
    DateTime? deadlineOrEventDate,
    required OpportunityStatus status,
    String? eligibility,
    String? requirements,
    String? nextAction,
    DateTime? nextActionDueDate,
    String? notes,
  }) async {
    await remoteDataSource.updateOpportunity(
      opportunityId: opportunityId,
      name: name,
      type: type.name,
      description: description,
      organizer: organizer,
      url: url,
      deadlineOrEventDate: deadlineOrEventDate,
      status: status.name,
      eligibility: eligibility,
      requirements: requirements,
      nextAction: nextAction,
      nextActionDueDate: nextActionDueDate,
      notes: notes,
    );
  }

  @override
  Future<void> deleteOpportunity(String opportunityId) async {
    await remoteDataSource.deleteOpportunity(opportunityId);
  }
}
