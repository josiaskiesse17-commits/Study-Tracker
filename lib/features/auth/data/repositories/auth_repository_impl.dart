import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Registration failed: no user returned.');
    }

    return UserModel.fromSupabase(
      user.id,
      user.email ?? email,
      user.userMetadata,
    );
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Login failed: no user returned.');
    }

    return UserModel.fromSupabase(
      user.id,
      user.email ?? email,
      user.userMetadata,
    );
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  User? getCurrentUser() {
    final user = remoteDataSource.getCurrentSupabaseUser();

    if (user == null) {
      return null;
    }

    return UserModel.fromSupabase(
      user.id,
      user.email ?? '',
      user.userMetadata,
    );
  }
}