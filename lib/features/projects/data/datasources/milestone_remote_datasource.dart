import 'package:dio/dio.dart';

import '../../../../core/network/network_exceptions.dart';
import '../models/milestone_model.dart';

class MilestoneRemoteDataSource {
  final Dio dio;

  MilestoneRemoteDataSource(this.dio);

  Future<List<MilestoneModel>> getMilestones(
    String projectId,
  ) async {
    try {
      final response = await dio.get(
        'milestones',
        queryParameters: {
          'project_id': 'eq.$projectId',
          'select': '*',
          'order': 'created_at.asc',
        },
      );

      final data = response.data;

      if (data is! List) {
        throw const NetworkException(
          'Invalid milestone data received from the server.',
        );
      }

      return data
          .map(
            (json) => MilestoneModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<MilestoneModel> createMilestone({
    required String projectId,
    required String title,
    String? description,
    String status = 'pending',
    DateTime? dueDate,
  }) async {
    try {
      final response = await dio.post(
        'milestones',
        queryParameters: {'select': '*'},
        options: Options(
          headers: {'Prefer': 'return=representation'},
        ),
        data: {
          'project_id': projectId,
          'title': title,
          'description': description,
          'status': status,
          'due_date': dueDate?.toIso8601String().split('T').first,
        },
      );

      final data = response.data;

      if (data is List && data.isNotEmpty) {
        return MilestoneModel.fromJson(
          Map<String, dynamic>.from(data.first as Map),
        );
      }

      if (data is Map) {
        return MilestoneModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw const NetworkException(
        'Invalid milestone data received from the server.',
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> updateMilestone({
    required String milestoneId,
    required String title,
    String? description,
    required String status,
    DateTime? dueDate,
  }) async {
    try {
      await dio.patch(
        'milestones',
        queryParameters: {
          'id': 'eq.$milestoneId',
        },
        data: {
          'title': title,
          'description': description,
          'status': status,
          'due_date': dueDate?.toIso8601String().split('T').first,
        },
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteMilestone(String milestoneId) async {
    try {
      await dio.delete(
        'milestones',
        queryParameters: {
          'id': 'eq.$milestoneId',
        },
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}