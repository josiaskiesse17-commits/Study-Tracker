import '../entities/opportunity.dart';

abstract class OpportunityRepository {
  Future<List<Opportunity>> getOpportunities();

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
  });

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
  });

  Future<void> deleteOpportunity(String opportunityId);
}
