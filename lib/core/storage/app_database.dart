import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _databaseName = 'study_track.db';
  static const _databaseVersion = 2;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      _databaseName,
    );

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE courses (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            progress REAL NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            course_id TEXT,
            title TEXT NOT NULL,
            description TEXT,
            completed INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute('''
            CREATE TABLE tasks (
              id TEXT PRIMARY KEY,
              user_id TEXT NOT NULL,
              course_id TEXT,
              title TEXT NOT NULL,
              description TEXT,
              completed INTEGER NOT NULL DEFAULT 0,
              created_at TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }
}