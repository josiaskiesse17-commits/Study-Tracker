import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_provider.dart';

final projectControllerProvider =
    AsyncNotifierProvider<ProjectController, List<Project>>(
  ProjectController.new,
);

class ProjectController extends AsyncNotifier<List<Project>> {
  late final ProjectRepository _repository;

  @override
  Future<List<Project>> build() async {
    _repository = ref.read(projectRepositoryProvider);
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