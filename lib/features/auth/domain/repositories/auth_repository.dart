import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String email,
    required String password,
    String? fullName,
  });

  Future<User> login({required String email, required String password});

  Future<void> logout();

  User? getCurrentUser();
}
