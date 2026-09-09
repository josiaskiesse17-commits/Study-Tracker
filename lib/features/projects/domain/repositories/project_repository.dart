import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects();

  Future<List<Project>> getCachedProjects();

  Future<Project> createProject({
    required String name,
    String? description,
    String status = 'planning',
    DateTime? deadline,
  });

  Future<void> updateProject({
    required String projectId,
    required String name,
    String? description,
    required String status,
    DateTime? deadline,
  });

  Future<void> deleteProject(String projectId);
}
