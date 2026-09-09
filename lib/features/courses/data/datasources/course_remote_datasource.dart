import 'package:dio/dio.dart';

import '../../../../core/network/network_exceptions.dart';
import '../models/course_model.dart';

class CourseRemoteDataSource {
  final Dio dio;

  CourseRemoteDataSource(this.dio);

  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await dio.get(
        'courses',
        queryParameters: {
          'select': '*',
          'order': 'created_at.desc',
        },
      );

      final data = response.data;

      if (data is! List) {
        throw const NetworkException(
          'Invalid course data received from the server.',
        );
      }

      return data
          .map(
            (json) => CourseModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<CourseModel> createCourse({
    required String userId,
    required String name,
    String? description,
    double progress = 0,
  }) async {
    try {
      final response = await dio.post(
        'courses',
        queryParameters: {
          'select': '*',
        },
        options: Options(
          headers: {
            'Prefer': 'return=representation',
          },
        ),
        data: {
          'user_id': userId,
          'name': name,
          'description': description,
          'progress': progress,
        },
      );

      final data = response.data;

      if (data is List && data.isNotEmpty) {
        return CourseModel.fromJson(
          Map<String, dynamic>.from(data.first as Map),
        );
      }

      if (data is Map) {
        return CourseModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw const NetworkException(
        'Invalid course data received from the server.',
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> updateCourse({
    required String courseId,
    required String name,
    String? description,
    required double progress,
  }) async {
    try {
      await dio.patch(
        'courses',
        queryParameters: {
          'id': 'eq.$courseId',
        },
        data: {
          'name': name,
          'description': description,
          'progress': progress,
        },
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await dio.delete(
        'courses',
        queryParameters: {
          'id': 'eq.$courseId',
        },
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}