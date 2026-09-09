import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor extends Interceptor {
  final SupabaseClient supabase;

  AuthInterceptor(this.supabase);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = supabase.auth.currentSession;

    if (session != null) {
      options.headers['Authorization'] =
          'Bearer ${session.accessToken}';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    try {
      final response = await supabase.auth.refreshSession();
      final newSession = response.session;

      if (newSession == null) {
        handler.next(err);
        return;
      }

      final requestOptions = err.requestOptions;

      requestOptions.headers['Authorization'] =
          'Bearer ${newSession.accessToken}';

      final dio = Dio();

      final retryResponse = await dio.fetch(
        requestOptions,
      );

      handler.resolve(retryResponse);
    } catch (_) {
      handler.next(err);
    }
  }
}