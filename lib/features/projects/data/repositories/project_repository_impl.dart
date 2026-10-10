import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_datasource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Project>> getProjects() async {
    return remoteDataSource.getProjects();
  }

  @override
  Future<Project> createProject({
    required String name,
    String? description,
    String status = 'planning',
    DateTime? deadline,
  }) async {
    return remoteDataSource.createProject(
      name: name,
      description: description,
      status: status,
      deadline: deadline,
    );
  }

  @override
  Future<void> updateProject({
    required String projectId,
    required String name,
    String? description,
    required String status,
    DateTime? deadline,
  }) async {
    await remoteDataSource.updateProject(
      projectId: projectId,
      name: name,
      description: description,
      status: status,
      deadline: deadline,
    );
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await remoteDataSource.deleteProject(projectId);
  }
}
