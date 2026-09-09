import 'package:dio/dio.dart';

import '../../../../core/network/network_exceptions.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSource(this.dio);

  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await dio.get(
        'work_items',
        queryParameters: {
          'select': '*',
          'order': 'created_at.desc',
        },
      );

      final data = response.data;

      if (data is! List) {
        throw const NetworkException(
          'Invalid work item data received from the server.',
        );
      }

      return data
          .map(
            (json) => TaskModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<TaskModel> createTask({
    required String userId,
    required String title,
    String? description,
    String? courseId,
    String? projectId,
    String type = 'other',
    String status = 'pending',
    String priority = 'medium',
    DateTime? dueDate,
  }) async {
    try {
      final response = await dio.post(
        'work_items',
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
          'title': title,
          'description': description,
          'course_id': courseId,
          'project_id': projectId,
          'type': type,
          'status': status,
          'priority': priority,
          'due_date': dueDate?.toIso8601String().split('T').first,
        },
      );

      final data = response.data;

      if (data is List && data.isNotEmpty) {
        return TaskModel.fromJson(
          Map<String, dynamic>.from(data.first as Map),
        );
      }

      if (data is Map) {
        return TaskModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw const NetworkException(
        'Invalid work item data received from the server.',
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    String? description,
    String? courseId,
    String? projectId,
    required String type,
    required String status,
    required String priority,
    DateTime? dueDate,
  }) async {
    try {
      await dio.patch(
        'work_items',
        queryParameters: {
          'id': 'eq.$taskId',
        },
        data: {
          'title': title,
          'description': description,
          'course_id': courseId,
          'project_id': projectId,
          'type': type,
          'status': status,
          'priority': priority,
          'due_date': dueDate?.toIso8601String().split('T').first,
        },
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await dio.delete(
        'work_items',
        queryParameters: {
          'id': 'eq.$taskId',
        },
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}