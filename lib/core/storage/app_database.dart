import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _databaseName = 'study_track.db';
  static const _databaseVersion = 5;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _openDatabase();

    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

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
          CREATE TABLE work_items (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            course_id TEXT,
            project_id TEXT,
            title TEXT NOT NULL,
            description TEXT,
            type TEXT NOT NULL DEFAULT 'other',
            status TEXT NOT NULL DEFAULT 'pending',
            priority TEXT NOT NULL DEFAULT 'medium',
            due_date TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE projects (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            status TEXT NOT NULL DEFAULT 'planning',
            deadline TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE milestones (
            id TEXT PRIMARY KEY,
            project_id TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            status TEXT NOT NULL DEFAULT 'pending',
            due_date TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },

      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
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

        if (oldVersion < 3) {
          await database.execute('''
            CREATE TABLE work_items (
              id TEXT PRIMARY KEY,
              user_id TEXT NOT NULL,
              course_id TEXT,
              project_id TEXT,
              title TEXT NOT NULL,
              description TEXT,
              type TEXT NOT NULL DEFAULT 'other',
              status TEXT NOT NULL DEFAULT 'pending',
              priority TEXT NOT NULL DEFAULT 'medium',
              due_date TEXT,
              created_at TEXT NOT NULL
            )
          ''');

          final oldTasks = await database.query('tasks');

          for (final task in oldTasks) {
            await database.insert(
              'work_items',
              {
                'id': task['id'],
                'user_id': task['user_id'],
                'course_id': task['course_id'],
                'project_id': null,
                'title': task['title'],
                'description': task['description'],
                'type': 'other',
                'status':
                    (task['completed'] as int? ?? 0) == 1
                        ? 'completed'
                        : 'pending',
                'priority': 'medium',
                'due_date': null,
                'created_at': task['created_at'],
              },
            );
          }

          await database.execute('DROP TABLE tasks');
        }

        if (oldVersion < 4) {
          await database.execute('''
            CREATE TABLE projects (
              id TEXT PRIMARY KEY,
              user_id TEXT NOT NULL,
              name TEXT NOT NULL,
              description TEXT,
              status TEXT NOT NULL DEFAULT 'planning',
              deadline TEXT,
              created_at TEXT NOT NULL
            )
          ''');
        }

        if (oldVersion < 5) {
          await database.execute('''
            CREATE TABLE milestones (
              id TEXT PRIMARY KEY,
              project_id TEXT NOT NULL,
              title TEXT NOT NULL,
              description TEXT,
              status TEXT NOT NULL DEFAULT 'pending',
              due_date TEXT,
              created_at TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }
}