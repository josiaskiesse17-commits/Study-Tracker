import 'package:dio/dio.dart';

import '../../../../core/network/network_exceptions.dart';
import '../models/project_model.dart';

class ProjectRemoteDataSource {
  final Dio dio;

  ProjectRemoteDataSource(this.dio);

  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await dio.get(
        'projects',
        queryParameters: {
          'select': '*',
          'order': 'created_at.desc',
        },
      );

      final data = response.data;

      if (data is! List) {
        throw const NetworkException(
          'Invalid project data received from the server.',
        );
      }

      return data
          .map(
            (json) => ProjectModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<ProjectModel> createProject({
    required String userId,
    required String name,
    String? description,
    String status = 'planning',
    DateTime? deadline,
  }) async {
    try {
      final response = await dio.post(
        'projects',
        queryParameters: {'select': '*'},
        options: Options(
          headers: {'Prefer': 'return=representation'},
        ),
        data: {
          'user_id': userId,
          'name': name,
          'description': description,
          'status': status,
          'deadline': deadline?.toIso8601String().split('T').first,
        },
      );

      final data = response.data;

      if (data is List && data.isNotEmpty) {
        return ProjectModel.fromJson(
          Map<String, dynamic>.from(data.first as Map),
        );
      }

      if (data is Map) {
        return ProjectModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw const NetworkException(
        'Invalid project data received from the server.',
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> updateProject({
    required String projectId,
    required String name,
    String? description,
    required String status,
    DateTime? deadline,
  }) async {
    try {
      await dio.patch(
        'projects',
        queryParameters: {
          'id': 'eq.$projectId',
        },
        data: {
          'name': name,
          'description': description,
          'status': status,
          'deadline': deadline?.toIso8601String().split('T').first,
        },
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await dio.delete(
        'projects',
        queryParameters: {
          'id': 'eq.$projectId',
        },
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}