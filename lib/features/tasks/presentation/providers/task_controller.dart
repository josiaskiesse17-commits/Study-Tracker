import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_provider.dart';

class TaskController extends AsyncNotifier<List<Task>> {
  TaskRepository get _repository {
    return ref.read(taskRepositoryProvider);
  }

  @override
  Future<List<Task>> build() async {
    return _repository.getTasks();
  }

  Future<void> refreshTasks() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _repository.getTasks(),
    );
  }

  Future<void> createTask({
    required String title,
    String? description,
    String? courseId,
  }) async {
    await _repository.createTask(
      title: title,
      description: description,
      courseId: courseId,
    );

    await refreshTasks();
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    String? description,
    String? courseId,
    required bool completed,
  }) async {
    await _repository.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      courseId: courseId,
      completed: completed,
    );

    await refreshTasks();
  }

  Future<void> toggleTask(Task task) async {
    await updateTask(
      taskId: task.id,
      title: task.title,
      description: task.description,
      courseId: task.courseId,
      completed: !task.completed,
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);

    await refreshTasks();
  }
}

final taskControllerProvider =
    AsyncNotifierProvider<TaskController, List<Task>>(
  TaskController.new,
);