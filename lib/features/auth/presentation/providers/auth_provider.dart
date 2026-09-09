import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.read(supabaseClientProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
  );
});

final registerProvider = Provider<Register>((ref) {
  return Register(
    ref.read(authRepositoryProvider),
  );
});

final loginProvider = Provider<Login>((ref) {
  return Login(
    ref.read(authRepositoryProvider),
  );
});

final logoutProvider = Provider<Logout>((ref) {
  return Logout(
    ref.read(authRepositoryProvider),
  );
});