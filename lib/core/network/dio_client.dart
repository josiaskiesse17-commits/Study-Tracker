import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_interceptor.dart';

class DioClient {
  final SupabaseClient supabase;

  late final Dio dio;

  DioClient(this.supabase) {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];

    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not configured.');
    }

    final publishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

    if (publishableKey == null || publishableKey.isEmpty) {
      throw Exception(
        'SUPABASE_PUBLISHABLE_KEY is not configured.',
      );
    }

    dio = Dio(
      BaseOptions(
        baseUrl: '$supabaseUrl/rest/v1/',
        headers: {
          'apikey': publishableKey,
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(supabase),
    );
  }
}