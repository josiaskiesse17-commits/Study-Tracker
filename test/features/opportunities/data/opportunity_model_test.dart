import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:study_tracker/features/opportunities/data/models/opportunity_model.dart';
import 'package:study_tracker/features/opportunities/domain/entities/opportunity.dart';

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('OpportunityModel.fromFirestore', () {
    test('parses all fields from Firestore document', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('opp-1');
      when(() => mockDoc.data()).thenReturn({
        'userId': 'user-1',
        'type': 'scholarship',
        'name': 'Google Scholarship',
        'description': 'Full ride',
        'organizer': 'Google',
        'url': 'https://google.com',
        'deadlineOrEventDate': '2026-12-01',
        'status': 'preparing',
        'eligibility': 'Students',
        'requirements': 'Apply online',
        'nextAction': 'Submit form',
        'nextActionDueDate': '2026-11-15',
        'notes': 'Remember references',
        'createdAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 10, 5)),
      });

      final model = OpportunityModel.fromFirestore(mockDoc);

      expect(model.id, 'opp-1');
      expect(model.userId, 'user-1');
      expect(model.type, OpportunityType.scholarship);
      expect(model.name, 'Google Scholarship');
      expect(model.description, 'Full ride');
      expect(model.organizer, 'Google');
      expect(model.url, 'https://google.com');
      expect(model.deadlineOrEventDate, DateTime(2026, 12, 1));
      expect(model.status, OpportunityStatus.preparing);
      expect(model.eligibility, 'Students');
      expect(model.requirements, 'Apply online');
      expect(model.nextAction, 'Submit form');
      expect(model.nextActionDueDate, DateTime(2026, 11, 15));
      expect(model.notes, 'Remember references');
      expect(model.createdAt, DateTime(2026, 10, 1));
      expect(model.updatedAt, DateTime(2026, 10, 5));
    });

    test('parses event type correctly', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('opp-2');
      when(() => mockDoc.data()).thenReturn({
        'userId': 'user-1',
        'type': 'event',
        'name': 'Tech Conference',
        'status': 'registered',
        'createdAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
      });

      final model = OpportunityModel.fromFirestore(mockDoc);

      expect(model.type, OpportunityType.event);
      expect(model.status, OpportunityStatus.registered);
    });

    test('handles missing optional fields gracefully', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('opp-3');
      when(() => mockDoc.data()).thenReturn({
        'userId': 'user-1',
        'type': 'scholarship',
        'name': 'Minimal',
        'status': 'considering',
        'createdAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
      });

      final model = OpportunityModel.fromFirestore(mockDoc);

      expect(model.description, isNull);
      expect(model.organizer, isNull);
      expect(model.url, isNull);
      expect(model.deadlineOrEventDate, isNull);
      expect(model.eligibility, isNull);
      expect(model.requirements, isNull);
      expect(model.nextAction, isNull);
      expect(model.nextActionDueDate, isNull);
      expect(model.notes, isNull);
      expect(model.updatedAt, isNull);
      expect(model.status, OpportunityStatus.considering);
    });

    test('parses unknown type as scholarship (default)', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('opp-4');
      when(() => mockDoc.data()).thenReturn({
        'userId': 'user-1',
        'type': 'unknown_type',
        'name': 'Test',
        'status': 'considering',
        'createdAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
      });

      final model = OpportunityModel.fromFirestore(mockDoc);

      expect(model.type, OpportunityType.scholarship);
    });
  });

  group('OpportunityModel.toFirestore', () {
    test('serializes all fields for Firestore', () {
      final model = OpportunityModel(
        id: 'opp-1',
        userId: 'user-1',
        type: OpportunityType.scholarship,
        name: 'Test Scholarship',
        description: 'A test',
        organizer: 'Org',
        url: 'https://example.com',
        deadlineOrEventDate: DateTime(2026, 12, 1),
        status: OpportunityStatus.applied,
        eligibility: 'Eligible',
        requirements: 'Reqs',
        nextAction: 'Action',
        nextActionDueDate: DateTime(2026, 11, 15),
        notes: 'Notes',
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 5),
      );

      final data = model.toFirestore();

      expect(data['userId'], 'user-1');
      expect(data['type'], 'scholarship');
      expect(data['name'], 'Test Scholarship');
      expect(data['description'], 'A test');
      expect(data['organizer'], 'Org');
      expect(data['url'], 'https://example.com');
      expect(data['deadlineOrEventDate'], '2026-12-01');
      expect(data['status'], 'applied');
      expect(data['eligibility'], 'Eligible');
      expect(data['requirements'], 'Reqs');
      expect(data['nextAction'], 'Action');
      expect(data['nextActionDueDate'], '2026-11-15');
      expect(data['notes'], 'Notes');
      expect(data['createdAt'], isA<Timestamp>());
      expect(data['updatedAt'], isA<Timestamp>());
    });

    test('omits updatedAt when null', () {
      final model = OpportunityModel(
        id: 'opp-1',
        userId: 'user-1',
        type: OpportunityType.scholarship,
        name: 'Test',
        status: OpportunityStatus.considering,
        createdAt: DateTime(2026, 10, 1),
      );

      final data = model.toFirestore();

      expect(data.containsKey('updatedAt'), isFalse);
    });

    test('round-trip preserves data', () {
      final original = OpportunityModel(
        id: 'opp-1',
        userId: 'user-1',
        type: OpportunityType.event,
        name: 'Conference',
        description: 'Annual tech conference',
        url: 'https://conf.example.com',
        deadlineOrEventDate: DateTime(2026, 6, 15),
        status: OpportunityStatus.registered,
        nextAction: 'Book hotel',
        nextActionDueDate: DateTime(2026, 5, 1),
        notes: 'Early bird ends soon',
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 2),
      );

      final data = original.toFirestore();
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('opp-1');
      when(() => mockDoc.data()).thenReturn(data);
      final restored = OpportunityModel.fromFirestore(mockDoc);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.type, original.type);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.url, original.url);
      expect(restored.deadlineOrEventDate, original.deadlineOrEventDate);
      expect(restored.status, original.status);
      expect(restored.nextAction, original.nextAction);
      expect(restored.nextActionDueDate, original.nextActionDueDate);
      expect(restored.notes, original.notes);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });
  });
}
