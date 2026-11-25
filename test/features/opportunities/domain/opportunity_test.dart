import 'package:flutter_test/flutter_test.dart';

import 'package:study_tracker/features/opportunities/domain/entities/opportunity.dart';

void main() {
  group('OpportunityStatus.forType', () {
    test('returns scholarship statuses for scholarship type', () {
      final statuses = OpportunityStatus.forType(OpportunityType.scholarship);
      expect(statuses, hasLength(6));
      expect(statuses, contains(OpportunityStatus.considering));
      expect(statuses, contains(OpportunityStatus.preparing));
      expect(statuses, contains(OpportunityStatus.applied));
      expect(statuses, contains(OpportunityStatus.awarded));
      expect(statuses, contains(OpportunityStatus.rejected));
      expect(statuses, contains(OpportunityStatus.withdrawn));
    });

    test('returns event statuses for event type', () {
      final statuses = OpportunityStatus.forType(OpportunityType.event);
      expect(statuses, hasLength(5));
      expect(statuses, contains(OpportunityStatus.considering));
      expect(statuses, contains(OpportunityStatus.registered));
      expect(statuses, contains(OpportunityStatus.attended));
      expect(statuses, contains(OpportunityStatus.missed));
      expect(statuses, contains(OpportunityStatus.cancelled));
    });

    test('does not include event-only statuses for scholarships', () {
      final statuses = OpportunityStatus.forType(OpportunityType.scholarship);
      expect(statuses, isNot(contains(OpportunityStatus.registered)));
      expect(statuses, isNot(contains(OpportunityStatus.attended)));
    });

    test('does not include scholarship-only statuses for events', () {
      final statuses = OpportunityStatus.forType(OpportunityType.event);
      expect(statuses, isNot(contains(OpportunityStatus.preparing)));
      expect(statuses, isNot(contains(OpportunityStatus.applied)));
    });
  });

  group('Opportunity entity', () {
    final opportunity = Opportunity(
      id: 'opp-1',
      userId: 'user-1',
      type: OpportunityType.scholarship,
      name: 'Google Summer of Code',
      description: 'Open source scholarship',
      organizer: 'Google',
      url: 'https://example.com',
      deadlineOrEventDate: DateTime(2026, 12, 1),
      status: OpportunityStatus.preparing,
      eligibility: 'Students enrolled in university',
      requirements: 'Submit a proposal',
      nextAction: 'Draft proposal',
      nextActionDueDate: DateTime(2026, 11, 15),
      notes: 'Remember to ask for references',
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 5),
    );

    test('copyWith updates fields', () {
      final updated = opportunity.copyWith(
        name: 'GSoC 2026',
        status: OpportunityStatus.applied,
      );
      expect(updated.name, 'GSoC 2026');
      expect(updated.status, OpportunityStatus.applied);
      expect(updated.id, opportunity.id);
      expect(updated.userId, opportunity.userId);
      expect(updated.type, opportunity.type);
    });

    test('copyWith can clear optional fields', () {
      final updated = opportunity.copyWith(description: null, notes: null);
      expect(updated.description, isNull);
      expect(updated.notes, isNull);
      expect(updated.name, opportunity.name);
    });

    test('isOverdue is true when deadline passed and not terminal', () {
      final overdue = Opportunity(
        id: 'opp-2',
        userId: 'user-1',
        type: OpportunityType.event,
        name: 'Past event',
        status: OpportunityStatus.considering,
        deadlineOrEventDate: DateTime(2020, 1, 1),
        createdAt: DateTime(2020, 1, 1),
      );
      expect(overdue.isOverdue, isTrue);
    });

    test('isOverdue is false when deadline is in the future', () {
      final notOverdue = Opportunity(
        id: 'opp-3',
        userId: 'user-1',
        type: OpportunityType.event,
        name: 'Future event',
        status: OpportunityStatus.considering,
        deadlineOrEventDate: DateTime(2030, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      );
      expect(notOverdue.isOverdue, isFalse);
    });

    test('isOverdue is false when no date', () {
      final noDate = Opportunity(
        id: 'opp-4',
        userId: 'user-1',
        type: OpportunityType.scholarship,
        name: 'No date',
        status: OpportunityStatus.considering,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(noDate.isOverdue, isFalse);
    });

    test('isOverdue is false for terminal statuses', () {
      final awarded = Opportunity(
        id: 'opp-5',
        userId: 'user-1',
        type: OpportunityType.scholarship,
        name: 'Awarded',
        status: OpportunityStatus.awarded,
        deadlineOrEventDate: DateTime(2020, 1, 1),
        createdAt: DateTime(2020, 1, 1),
      );
      expect(awarded.isOverdue, isFalse);

      final attended = Opportunity(
        id: 'opp-6',
        userId: 'user-1',
        type: OpportunityType.event,
        name: 'Attended',
        status: OpportunityStatus.attended,
        deadlineOrEventDate: DateTime(2020, 1, 1),
        createdAt: DateTime(2020, 1, 1),
      );
      expect(attended.isOverdue, isFalse);
    });

    test('hasNextAction is true when next action is set', () {
      expect(opportunity.hasNextAction, isTrue);
    });

    test('hasNextAction is false when next action is empty', () {
      final noAction = Opportunity(
        id: 'opp-7',
        userId: 'user-1',
        type: OpportunityType.scholarship,
        name: 'No action',
        status: OpportunityStatus.considering,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(noAction.hasNextAction, isFalse);
    });

    test('relevantDate returns deadlineOrEventDate', () {
      expect(opportunity.relevantDate, opportunity.deadlineOrEventDate);
    });

    test('fromValue parses valid status strings', () {
      expect(OpportunityStatus.fromValue('applied'), OpportunityStatus.applied);
      expect(
        OpportunityStatus.fromValue('registered'),
        OpportunityStatus.registered,
      );
    });

    test('fromValue defaults to considering for unknown strings', () {
      expect(
        OpportunityStatus.fromValue('unknown_status'),
        OpportunityStatus.considering,
      );
    });
  });
}
