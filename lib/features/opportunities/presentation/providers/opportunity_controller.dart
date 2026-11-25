import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/providers/opportunity_provider.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/repositories/opportunity_repository.dart';

final opportunityControllerProvider =
    AsyncNotifierProvider<OpportunityController, List<Opportunity>>(
      OpportunityController.new,
    );

class OpportunityController extends AsyncNotifier<List<Opportunity>> {
  OpportunityRepository get _repository =>
      ref.read(opportunityRepositoryProvider);

  @override
  Future<List<Opportunity>> build() async {
    // Rebuilds automatically whenever the logged-in user changes.
    ref.watch(authControllerProvider.select((s) => s.user?.id));

    return _repository.getOpportunities();
  }

  Future<void> refreshOpportunities() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() => _repository.getOpportunities());
  }

  Future<void> createOpportunity({
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
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.createOpportunity(
        name: name,
        type: type,
        status: status,
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

      return _repository.getOpportunities();
    });
  }

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
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.updateOpportunity(
        opportunityId: opportunityId,
        name: name,
        type: type,
        description: description,
        organizer: organizer,
        url: url,
        deadlineOrEventDate: deadlineOrEventDate,
        status: status,
        eligibility: eligibility,
        requirements: requirements,
        nextAction: nextAction,
        nextActionDueDate: nextActionDueDate,
        notes: notes,
      );

      return _repository.getOpportunities();
    });
  }

  Future<void> deleteOpportunity(String opportunityId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.deleteOpportunity(opportunityId);

      return _repository.getOpportunities();
    });
  }
}
