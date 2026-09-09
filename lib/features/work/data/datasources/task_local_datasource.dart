import 'package:sqflite/sqflite.dart';

import '../../../../core/storage/app_database.dart';
import '../models/task_model.dart';

class TaskLocalDataSource {
  final AppDatabase database;

  TaskLocalDataSource(this.database);

  Future<List<TaskModel>> getTasks(String userId) async {
    final db = await database.database;

    final rows = await db.query(
      'work_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return rows
        .map(
          (row) => TaskModel.fromJson(
            Map<String, dynamic>.from(row),
          ),
        )
        .toList();
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final db = await database.database;

    final batch = db.batch();

    for (final task in tasks) {
      batch.insert(
        'work_items',
        task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> saveTask(TaskModel task) async {
    final db = await database.database;

    await db.insert(
      'work_items',
      task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await database.database;

    await db.update(
      'work_items',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String taskId) async {
    final db = await database.database;

    await db.delete(
      'work_items',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> clearTasks(String userId) async {
    final db = await database.database;

    await db.delete(
      'work_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}