import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => message;
}

NetworkException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkException(
        'The request timed out. Please try again.',
      );

    case DioExceptionType.connectionError:
      return const NetworkException(
        'No internet connection. Please check your network.',
      );

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;

      if (statusCode == 401) {
        return const NetworkException(
          'Your session has expired. Please log in again.',
        );
      }

      if (statusCode == 403) {
        return const NetworkException(
          'You do not have permission to perform this action.',
        );
      }

      if (statusCode == 404) {
        return const NetworkException(
          'The requested resource was not found.',
        );
      }

      if (statusCode != null && statusCode >= 500) {
        return const NetworkException(
          'The server is currently unavailable. Please try again later.',
        );
      }

      return NetworkException(
        error.response?.data?['message']?.toString() ??
            'The server returned an error.',
      );

    default:
      return const NetworkException(
        'Something went wrong. Please try again.',
      );
  }
}