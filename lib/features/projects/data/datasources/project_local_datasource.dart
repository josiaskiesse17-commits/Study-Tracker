import 'package:sqflite/sqflite.dart';

import '../../../../core/storage/app_database.dart';
import '../models/project_model.dart';

class ProjectLocalDataSource {
  final AppDatabase database;

  ProjectLocalDataSource(this.database);

  Future<List<ProjectModel>> getProjects(String userId) async {
    final db = await database.database;

    final rows = await db.query(
      'projects',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return rows
        .map(
          (row) => ProjectModel.fromJson(
            Map<String, dynamic>.from(row),
          ),
        )
        .toList();
  }

  Future<void> saveProjects(List<ProjectModel> projects) async {
    final db = await database.database;
    final batch = db.batch();

    for (final project in projects) {
      batch.insert(
        'projects',
        project.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> saveProject(ProjectModel project) async {
    final db = await database.database;

    await db.insert(
      'projects',
      project.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProject(ProjectModel project) async {
    final db = await database.database;

    await db.update(
      'projects',
      project.toJson(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<void> deleteProject(String projectId) async {
    final db = await database.database;

    await db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }
}