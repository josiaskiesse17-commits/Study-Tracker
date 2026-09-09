import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<WorkItem>> getTasks();

  Future<List<WorkItem>> getCachedTasks();

  Future<WorkItem> createTask({
    required String title,
    String? description,
    String? courseId,
    String? projectId,
    String type = 'other',
    String status = 'pending',
    String priority = 'medium',
    DateTime? dueDate,
  });

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
  });

  Future<void> deleteTask(String taskId);
}