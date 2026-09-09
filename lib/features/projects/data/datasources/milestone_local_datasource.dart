import 'package:sqflite/sqflite.dart';

import '../../../../core/storage/app_database.dart';
import '../models/milestone_model.dart';

class MilestoneLocalDataSource {
  final AppDatabase database;

  MilestoneLocalDataSource(this.database);

  Future<List<MilestoneModel>> getMilestones(
    String projectId,
  ) async {
    final db = await database.database;

    final rows = await db.query(
      'milestones',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'created_at ASC',
    );

    return rows
        .map(
          (row) => MilestoneModel.fromJson(
            Map<String, dynamic>.from(row),
          ),
        )
        .toList();
  }

  Future<void> saveMilestones(
    List<MilestoneModel> milestones,
  ) async {
    final db = await database.database;
    final batch = db.batch();

    for (final milestone in milestones) {
      batch.insert(
        'milestones',
        milestone.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> saveMilestone(
    MilestoneModel milestone,
  ) async {
    final db = await database.database;

    await db.insert(
      'milestones',
      milestone.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMilestone(
    MilestoneModel milestone,
  ) async {
    final db = await database.database;

    await db.update(
      'milestones',
      milestone.toJson(),
      where: 'id = ?',
      whereArgs: [milestone.id],
    );
  }

  Future<void> deleteMilestone(
    String milestoneId,
  ) async {
    final db = await database.database;

    await db.delete(
      'milestones',
      where: 'id = ?',
      whereArgs: [milestoneId],
    );
  }
}