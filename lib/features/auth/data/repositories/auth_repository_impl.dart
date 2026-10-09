import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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
    try {
      final credential = await remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Registration failed: no user returned.');
      }

      return UserModel.fromFirebase(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await remoteDataSource.login(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Login failed: no user returned.');
      }

      return UserModel.fromFirebase(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  User? getCurrentUser() {
    final user = remoteDataSource.getCurrentUser();
    if (user == null) {
      return null;
    }
    return UserModel.fromFirebase(user);
  }

  Exception _mapFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('An account already exists with this email.');
      case 'invalid-credential':
        return Exception('Invalid credentials. Please check your email and password.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'user-not-found':
        return Exception('No account found with this email.');
      case 'weak-password':
        return Exception('Password is too weak. Please use at least 6 characters.');
      case 'invalid-email':
        return Exception('Invalid email address.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      default:
        return Exception(e.message ?? 'Authentication failed. Please try again.');
    }
  }
}