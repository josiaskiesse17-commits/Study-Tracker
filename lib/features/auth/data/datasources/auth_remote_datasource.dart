import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSource(this.supabase);

Future<AuthResponse> register({
  required String email,
  required String password,
  String? fullName,
}) {
  return supabase.auth.signUp(
    email: email,
    password: password,
    data: {
      'full_name': ?fullName,
    },
  );
}

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() {
    return supabase.auth.signOut();
  }

  Session? getCurrentSession() {
    return supabase.auth.currentSession;
  }

  User? getCurrentSupabaseUser() {
    return supabase.auth.currentUser;
  }

  Future<Session?> refreshSession() async {
    final response = await supabase.auth.refreshSession();
    return response.session;
  }
}