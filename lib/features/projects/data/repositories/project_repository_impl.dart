import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_datasource.dart';
import '../datasources/project_remote_datasource.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;
  final ProjectLocalDataSource localDataSource;
  final Connectivity connectivity;
  final SupabaseClient supabase;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
    required this.supabase,
  });

  String get _userId {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in.');
    }

    return user.id;
  }

  Future<bool> _isOnline() async {
    final results = await connectivity.checkConnectivity();

    return results.any((result) => result != ConnectivityResult.none);
  }

  @override
  Future<List<Project>> getProjects() async {
    final userId = _userId;

    if (await _isOnline()) {
      try {
        final projects = await remoteDataSource.getProjects();

        await localDataSource.saveProjects(projects);

        return projects;
      } catch (e) {
        debugPrint('Remote projects failed: $e');

        return localDataSource.getProjects(userId);
      }
    }

    return localDataSource.getProjects(userId);
  }

  @override
  Future<List<Project>> getCachedProjects() {
    return localDataSource.getProjects(_userId);
  }

  @override
  Future<Project> createProject({
    required String name,
    String? description,
    String status = 'planning',
    DateTime? deadline,
  }) async {
    if (!await _isOnline()) {
      throw Exception(
        'You are offline. Creating a project requires a connection.',
      );
    }

    final project = await remoteDataSource.createProject(
      userId: _userId,
      name: name,
      description: description,
      status: status,
      deadline: deadline,
    );

    await localDataSource.saveProject(project);

    return project;
  }

  @override
  Future<void> updateProject({
    required String projectId,
    required String name,
    String? description,
    required String status,
    DateTime? deadline,
  }) async {
    if (!await _isOnline()) {
      throw Exception(
        'You are offline. Updating a project requires a connection.',
      );
    }

    await remoteDataSource.updateProject(
      projectId: projectId,
      name: name,
      description: description,
      status: status,
      deadline: deadline,
    );

    final cachedProjects = await localDataSource.getProjects(_userId);

    final existingIndex = cachedProjects.indexWhere(
      (project) => project.id == projectId,
    );

    if (existingIndex == -1) {
      return;
    }

    final existing = cachedProjects[existingIndex];

    final updated = ProjectModel(
      id: existing.id,
      userId: existing.userId,
      name: name,
      description: description,
      status: status,
      deadline: deadline,
      createdAt: existing.createdAt,
    );

    await localDataSource.updateProject(updated);
  }

  @override
  Future<void> deleteProject(String projectId) async {
    if (!await _isOnline()) {
      throw Exception(
        'You are offline. Deleting a project requires a connection.',
      );
    }

    await remoteDataSource.deleteProject(projectId);

    await localDataSource.deleteProject(projectId);
  }
}
