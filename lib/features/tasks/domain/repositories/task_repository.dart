import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();

  Future<List<Task>> getCachedTasks();

  Future<Task> createTask({
    required String title,
    String? description,
    String? courseId,
  });

  Future<void> updateTask({
    required String taskId,
    required String title,
    String? description,
    String? courseId,
    required bool completed,
  });

  Future<void> deleteTask(String taskId);
}