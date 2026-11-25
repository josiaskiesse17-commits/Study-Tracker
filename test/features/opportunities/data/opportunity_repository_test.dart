import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:study_tracker/features/opportunities/data/datasources/opportunity_remote_datasource.dart';
import 'package:study_tracker/features/opportunities/data/models/opportunity_model.dart';
import 'package:study_tracker/features/opportunities/data/repositories/opportunity_repository_impl.dart';
import 'package:study_tracker/features/opportunities/domain/entities/opportunity.dart';

class MockOpportunityRemoteDataSource extends Mock
    implements OpportunityRemoteDataSource {}

void main() {
  late MockOpportunityRemoteDataSource remoteDataSource;
  late OpportunityRepositoryImpl repository;

  const userId = 'user-123';

  final opportunity = OpportunityModel(
    id: 'opp-1',
    userId: userId,
    type: OpportunityType.scholarship,
    name: 'Test Scholarship',
    status: OpportunityStatus.considering,
    createdAt: DateTime(2026, 9, 1),
  );

  setUp(() {
    remoteDataSource = MockOpportunityRemoteDataSource();
    repository = OpportunityRepositoryImpl(remoteDataSource);
  });

  group('getOpportunities', () {
    test('returns opportunities from remote data source', () async {
      when(() => remoteDataSource.getOpportunities())
          .thenAnswer((_) async => [opportunity]);

      final result = await repository.getOpportunities();

      expect(result, [opportunity]);
      verify(() => remoteDataSource.getOpportunities()).called(1);
    });

    test('returns an empty list when no opportunities', () async {
      when(() => remoteDataSource.getOpportunities())
          .thenAnswer((_) async => []);

      final result = await repository.getOpportunities();

      expect(result, isEmpty);
      verify(() => remoteDataSource.getOpportunities()).called(1);
    });
  });

  group('createOpportunity', () {
    test('creates opportunity via remote data source', () async {
      when(
        () => remoteDataSource.createOpportunity(
          name: any(named: 'name'),
          type: any(named: 'type'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => opportunity);

      final result = await repository.createOpportunity(
        name: 'Test Scholarship',
        type: OpportunityType.scholarship,
        status: OpportunityStatus.considering,
      );

      expect(result, opportunity);
      verify(
        () => remoteDataSource.createOpportunity(
          name: 'Test Scholarship',
          type: 'scholarship',
          status: 'considering',
        ),
      ).called(1);
    });
  });

  group('updateOpportunity', () {
    test('updates opportunity via remote data source', () async {
      when(
        () => remoteDataSource.updateOpportunity(
          opportunityId: any(named: 'opportunityId'),
          name: any(named: 'name'),
          type: any(named: 'type'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async {});

      await repository.updateOpportunity(
        opportunityId: 'opp-1',
        name: 'Updated Name',
        type: OpportunityType.scholarship,
        status: OpportunityStatus.applied,
      );

      verify(
        () => remoteDataSource.updateOpportunity(
          opportunityId: 'opp-1',
          name: 'Updated Name',
          type: 'scholarship',
          status: 'applied',
        ),
      ).called(1);
    });
  });

  group('deleteOpportunity', () {
    test('deletes opportunity via remote data source', () async {
      when(() => remoteDataSource.deleteOpportunity(any()))
          .thenAnswer((_) async {});

      await repository.deleteOpportunity('opp-1');

      verify(() => remoteDataSource.deleteOpportunity('opp-1')).called(1);
    });
  });
}
