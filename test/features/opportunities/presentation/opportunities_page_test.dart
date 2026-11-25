import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_tracker/features/auth/domain/entities/user.dart';
import 'package:study_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:study_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:study_tracker/features/opportunities/data/providers/opportunity_provider.dart';
import 'package:study_tracker/features/opportunities/domain/entities/opportunity.dart';
import 'package:study_tracker/features/opportunities/domain/repositories/opportunity_repository.dart';
import 'package:study_tracker/features/opportunities/presentation/pages/opportunities_page.dart';
import 'package:study_tracker/l10n/app_localizations.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<User> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<User> login({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    throw UnimplementedError();
  }

  @override
  User? getCurrentUser() => null;
}

class FakeOpportunityRepository implements OpportunityRepository {
  final List<Opportunity> _opportunities = [];

  void setOpportunities(List<Opportunity> opportunities) {
    _opportunities.clear();
    _opportunities.addAll(opportunities);
  }

  @override
  Future<List<Opportunity>> getOpportunities() async =>
      List.from(_opportunities);

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
    final opp = Opportunity(
      id: 'new-${_opportunities.length + 1}',
      userId: 'user-1',
      type: type,
      name: name,
      status: status,
      description: description,
      createdAt: DateTime.now(),
    );
    _opportunities.add(opp);
    return opp;
  }

  @override
  Future<void> updateOpportunity({
    required String opportunityId,
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
    final index = _opportunities.indexWhere((o) => o.id == opportunityId);
    if (index != -1) {
      _opportunities[index] = _opportunities[index].copyWith(
        name: name,
        type: type,
        status: status,
        description: description,
      );
    }
  }

  @override
  Future<void> deleteOpportunity(String opportunityId) async {
    _opportunities.removeWhere((o) => o.id == opportunityId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OpportunitiesPage', () {
    Widget _makeTestPage({
      required List<Opportunity> opportunities,
      required FakeOpportunityRepository fakeRepo,
    }) {
      fakeRepo.setOpportunities(opportunities);

      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => FakeAuthRepository()),
          opportunityRepositoryProvider.overrideWith((ref) => fakeRepo),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const OpportunitiesPage(),
        ),
      );
    }

    testWidgets('shows empty state when no opportunities', (tester) async {
      final fakeRepo = FakeOpportunityRepository();

      await tester.pumpWidget(
        _makeTestPage(opportunities: [], fakeRepo: fakeRepo),
      );

      await tester.pumpAndSettle();

      expect(find.text('No opportunities yet'), findsOneWidget);
      // "Create opportunity" appears on the empty state card and FAB label
      expect(find.text('Create opportunity'), findsAtLeastNWidgets(2));
    });

    testWidgets('shows list of opportunities', (tester) async {
      final fakeRepo = FakeOpportunityRepository();
      final opportunities = [
        Opportunity(
          id: 'opp-1',
          userId: 'user-1',
          type: OpportunityType.scholarship,
          name: 'Google Scholarship',
          status: OpportunityStatus.preparing,
          deadlineOrEventDate: DateTime(2026, 12, 1),
          createdAt: DateTime(2026, 10, 1),
        ),
        Opportunity(
          id: 'opp-2',
          userId: 'user-1',
          type: OpportunityType.event,
          name: 'Tech Conference',
          status: OpportunityStatus.registered,
          deadlineOrEventDate: DateTime(2026, 6, 15),
          createdAt: DateTime(2026, 10, 1),
        ),
      ];

      await tester.pumpWidget(
        _makeTestPage(opportunities: opportunities, fakeRepo: fakeRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Google Scholarship'), findsOneWidget);
      expect(find.text('Tech Conference'), findsOneWidget);
      expect(find.text('No opportunities yet'), findsNothing);
    });

    testWidgets('filter chips are shown', (tester) async {
      final fakeRepo = FakeOpportunityRepository();

      await tester.pumpWidget(
        _makeTestPage(opportunities: [], fakeRepo: fakeRepo),
      );

      expect(find.text('Scholarships'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
    });

    testWidgets('create button opens dialog', (tester) async {
      final fakeRepo = FakeOpportunityRepository();

      await tester.pumpWidget(
        _makeTestPage(opportunities: [], fakeRepo: fakeRepo),
      );

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Opportunity name'), findsOneWidget);
    });
  });
}
