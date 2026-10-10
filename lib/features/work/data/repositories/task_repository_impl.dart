import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<WorkItem>> getTasks() async {
    return remoteDataSource.getTasks();
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
    return remoteDataSource.createTask(
      title: title,
      description: description,
      courseId: courseId,
      projectId: projectId,
      type: type,
      status: status,
      priority: priority,
      dueDate: dueDate,
    );
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
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await remoteDataSource.deleteTask(taskId);
  }
}