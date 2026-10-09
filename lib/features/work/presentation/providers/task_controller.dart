import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_provider.dart';

final taskControllerProvider =
    AsyncNotifierProvider<TaskController, List<WorkItem>>(
  TaskController.new,
);

class TaskController extends AsyncNotifier<List<WorkItem>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  @override
  Future<List<WorkItem>> build() async {
    // Rebuilds automatically whenever the logged-in user changes.
    ref.watch(authControllerProvider.select((s) => s.user?.id));

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
    String? projectId,
    String type = 'other',
    String status = 'pending',
    String priority = 'medium',
    DateTime? dueDate,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.createTask(
        title: title,
        description: description,
        courseId: courseId,
        projectId: projectId,
        type: type,
        status: status,
        priority: priority,
        dueDate: dueDate,
      );

      return _repository.getTasks();
    });
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
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.updateTask(
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

      return _repository.getTasks();
    });
  }

  Future<void> deleteTask(String taskId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.deleteTask(taskId);

      return _repository.getTasks();
    });
  }
}