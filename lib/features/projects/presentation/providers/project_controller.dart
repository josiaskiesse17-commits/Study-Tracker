import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_provider.dart';

final projectControllerProvider =
    AsyncNotifierProvider<ProjectController, List<Project>>(
  ProjectController.new,
);

class ProjectController extends AsyncNotifier<List<Project>> {
  ProjectRepository get _repository => ref.read(projectRepositoryProvider);

  @override
  Future<List<Project>> build() async {
    // Watch the current user ID so the list reloads when the logged-in user changes
    ref.watch(authControllerProvider.select((s) => s.user?.id));

    return _repository.getProjects();
  }

  Future<void> refreshProjects() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => _repository.getProjects(),
    );
  }

  Future<void> createProject({
    required String name,
    String? description,
    String status = 'planning',
    DateTime? deadline,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.createProject(
        name: name,
        description: description,
        status: status,
        deadline: deadline,
      );

      return _repository.getProjects();
    });
  }

  Future<void> updateProject({
    required String projectId,
    required String name,
    String? description,
    required String status,
    DateTime? deadline,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.updateProject(
        projectId: projectId,
        name: name,
        description: description,
        status: status,
        deadline: deadline,
      );

      return _repository.getProjects();
    });
  }

  Future<void> deleteProject(String projectId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.deleteProject(projectId);

      return _repository.getProjects();
    });
  }
}