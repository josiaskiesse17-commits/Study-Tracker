import 'package:flutter_test/flutter_test.dart';

import 'package:study_tracker/features/auth/domain/entities/user.dart';
import 'package:study_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:study_tracker/features/auth/domain/usecases/login.dart';
import 'package:study_tracker/features/auth/domain/usecases/logout.dart';
import 'package:study_tracker/features/auth/domain/usecases/register.dart';

class FakeAuthRepository implements AuthRepository {
  User? currentUser;
  String? lastEmail;
  String? lastPassword;
  String? lastFullName;
  bool logoutCalled = false;

  @override
  Future<User> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    lastEmail = email;
    lastPassword = password;
    lastFullName = fullName;

    currentUser = User(
      id: 'user-1',
      email: email,
      fullName: fullName,
    );

    return currentUser!;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;

    currentUser = User(
      id: 'user-1',
      email: email,
      fullName: 'Test User',
    );

    return currentUser!;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    currentUser = null;
  }

  @override
  User? getCurrentUser() {
    return currentUser;
  }
}

void main() {
  test('Register calls repository with correct values', () async {
    final repository = FakeAuthRepository();
    final register = Register(repository);

    final user = await register(
      email: 'test@example.com',
      password: 'password123',
      fullName: 'Test User',
    );

    expect(user.email, 'test@example.com');
    expect(user.fullName, 'Test User');
    expect(repository.lastEmail, 'test@example.com');
    expect(repository.lastPassword, 'password123');
    expect(repository.lastFullName, 'Test User');
  });

  test('Login calls repository with correct values', () async {
    final repository = FakeAuthRepository();
    final login = Login(repository);

    final user = await login(
      email: 'test@example.com',
      password: 'password123',
    );

    expect(user.email, 'test@example.com');
    expect(repository.lastEmail, 'test@example.com');
    expect(repository.lastPassword, 'password123');
  });

  test('Logout calls repository', () async {
    final repository = FakeAuthRepository();
    final logout = Logout(repository);

    await logout();

    expect(repository.logoutCalled, true);
  });
}
