import 'package:sqflite/sqflite.dart';

import '../../../../core/storage/app_database.dart';
import '../models/course_model.dart';

class CourseLocalDataSource {
  final AppDatabase database;

  CourseLocalDataSource(this.database);

  Future<List<CourseModel>> getCourses(String userId) async {
    final db = await database.database;

    final rows = await db.query(
      'courses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return rows
        .map(
          (row) => CourseModel.fromJson(
            Map<String, dynamic>.from(row),
          ),
        )
        .toList();
  }

  Future<void> saveCourses(
    List<CourseModel> courses,
  ) async {
    final db = await database.database;

    final batch = db.batch();

    for (final course in courses) {
      batch.insert(
        'courses',
        course.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> saveCourse(CourseModel course) async {
    final db = await database.database;

    await db.insert(
      'courses',
      course.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCourse(CourseModel course) async {
    final db = await database.database;

    await db.update(
      'courses',
      course.toJson(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<void> deleteCourse(String courseId) async {
    final db = await database.database;

    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }

  Future<void> clearCourses(String userId) async {
    final db = await database.database;

    await db.delete(
      'courses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}