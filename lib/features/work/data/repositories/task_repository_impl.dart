import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  final Connectivity connectivity;
  final SupabaseClient supabase;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
    required this.supabase,
  });

  String get _userId {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in.');
    }

    return user.id;
  }

  Future<bool> _isOnline() async {
    final results = await connectivity.checkConnectivity();

    return results.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  @override
  Future<List<WorkItem>> getTasks() async {
    final userId = _userId;

    if (await _isOnline()) {
      try {
        final tasks = await remoteDataSource.getTasks();

        await localDataSource.saveTasks(tasks);

        return tasks;
      } catch (e) {
        debugPrint('Remote work items failed: $e');

        return localDataSource.getTasks(userId);
      }
    }

    return localDataSource.getTasks(userId);
  }

  @override
  Future<List<WorkItem>> getCachedTasks() {
    return localDataSource.getTasks(_userId);
  }

  @override
  Future<WorkItem> createTask({
    required String title,
    String? description,
    String? courseId,
    String? projectId,
    String type = 'other',
    String status = 'pending',
    String priority = 'medium',
    DateTime? dueDate,
  }) async {
    if (!await _isOnline()) {
      throw Exception(
        'You are offline. Creating work requires a connection.',
      );
    }

    final task = await remoteDataSource.createTask(
      userId: _userId,
      title: title,
      description: description,
      courseId: courseId,
      projectId: projectId,
      type: type,
      status: status,
      priority: priority,
      dueDate: dueDate,
    );

    await localDataSource.saveTask(task);

    return task;
  }

  @override
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
    if (!await _isOnline()) {
      throw Exception(
        'You are offline. Updating work requires a connection.',
      );
    }

    await remoteDataSource.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      courseId: courseId,
      projectId: projectId,
      type: type,
      status: status,
      priority: priority,
      dueDate: dueDate,
    );

    final cachedTasks = await localDataSource.getTasks(_userId);

    final existingIndex = cachedTasks.indexWhere(
      (task) => task.id == taskId,
    );

    if (existingIndex == -1) {
      return;
    }

    final existing = cachedTasks[existingIndex];

    final updated = TaskModel(
      id: existing.id,
      userId: existing.userId,
      courseId: courseId,
      projectId: projectId,
      title: title,
      description: description,
      type: type,
      status: status,
      priority: priority,
      dueDate: dueDate,
      createdAt: existing.createdAt,
    );

    await localDataSource.updateTask(updated);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    if (!await _isOnline()) {
      throw Exception(
        'You are offline. Deleting work requires a connection.',
      );
    }

    await remoteDataSource.deleteTask(taskId);

    await localDataSource.deleteTask(taskId);
  }
}