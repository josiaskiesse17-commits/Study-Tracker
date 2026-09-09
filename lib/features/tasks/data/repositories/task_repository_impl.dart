import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../core/storage/app_database.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  final AppDatabase database;
  final SupabaseClient supabase;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.database,
    required this.supabase,
  });

  @override
  Future<List<Task>> getTasks() async {
    final userId = _getCurrentUserId();

    final connectivity = await Connectivity().checkConnectivity();

    final hasConnection = connectivity.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      return localDataSource.getTasks(userId);
    }

    try {
      final tasks = await remoteDataSource.getTasks();

      await localDataSource.saveTasks(tasks);

      return tasks;
    } on NetworkException {
      final cachedTasks = await localDataSource.getTasks(userId);

      if (cachedTasks.isNotEmpty) {
        return cachedTasks;
      }

      rethrow;
    }
  }

  @override
  Future<List<Task>> getCachedTasks() {
    final userId = _getCurrentUserId();

    return localDataSource.getTasks(userId);
  }

  @override
  Future<Task> createTask({
    required String title,
    String? description,
    String? courseId,
  }) async {
    final userId = _getCurrentUserId();

    final connectivity = await Connectivity().checkConnectivity();

    final hasConnection = connectivity.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      throw const NetworkException(
        'You need an internet connection to create a task.',
      );
    }

    final task = await remoteDataSource.createTask(
      userId: userId,
      title: title,
      description: description,
      courseId: courseId,
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
    required bool completed,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();

    final hasConnection = connectivity.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      throw const NetworkException(
        'You need an internet connection to update a task.',
      );
    }

    await remoteDataSource.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      courseId: courseId,
      completed: completed,
    );

    final userId = _getCurrentUserId();

    final cachedTasks = await localDataSource.getTasks(userId);

    final existingTask = cachedTasks.firstWhere(
      (task) => task.id == taskId,
      orElse: () => throw const NetworkException(
        'Task was not found in local storage.',
      ),
    );

    final updatedTask = TaskModel(
      id: existingTask.id,
      userId: existingTask.userId,
      courseId: courseId,
      title: title,
      description: description,
      completed: completed,
      createdAt: existingTask.createdAt,
    );

    await localDataSource.updateTask(updatedTask);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final connectivity = await Connectivity().checkConnectivity();

    final hasConnection = connectivity.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      throw const NetworkException(
        'You need an internet connection to delete a task.',
      );
    }

    await remoteDataSource.deleteTask(taskId);

    await localDataSource.deleteTask(taskId);
  }

  String _getCurrentUserId() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw const NetworkException(
        'You must be logged in to access tasks.',
      );
    }

    return user.id;
  }
}