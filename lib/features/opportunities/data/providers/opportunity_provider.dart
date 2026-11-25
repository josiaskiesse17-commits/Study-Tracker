import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/opportunity_remote_datasource.dart';
import '../../data/repositories/opportunity_repository_impl.dart';
import '../../domain/repositories/opportunity_repository.dart';

final opportunityRemoteDataSourceProvider =
    Provider<OpportunityRemoteDataSource>((ref) {
      return OpportunityRemoteDataSource();
    });

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepositoryImpl(
    ref.read(opportunityRemoteDataSourceProvider),
  );
});
