import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException;

import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import 'auth_provider.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final Register _register;
  late final Login _login;
  late final Logout _logout;

  @override
  AuthState build() {
    _register = ref.read(registerProvider);
    _login = ref.read(loginProvider);
    _logout = ref.read(logoutProvider);

    final currentUser = ref
        .read(authRepositoryProvider)
        .getCurrentUser();

    return AuthState(
      user: currentUser,
    );
  }

  Future<void> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final user = await _register(
        email: email,
        password: password,
        fullName: fullName,
      );

      state = AuthState(
        user: user,
      );
    } catch (e) {
      state = AuthState(
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final user = await _login(
        email: email,
        password: password,
      );

      state = AuthState(
        user: user,
      );
    } catch (e) {
      state = AuthState(
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await _logout();

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  String _getErrorMessage(Object error) {
    if (error is AuthException) {
      return error.message;
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);