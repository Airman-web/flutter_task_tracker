import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  // Singleton pattern: only one DatabaseHelper ever exists in the whole app.
  // Every screen that needs the database calls DatabaseHelper.instance,
  // so everyone shares the same open connection instead of opening
  // a new one every time, which would be wasteful and error-prone.
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  // Gets the database, opening it the first time it's needed
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // getDatabasesPath() finds the correct, allowed storage folder
    // on whatever device the app is running on
    String path = join(await getDatabasesPath(), 'task_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Runs once, the very first time the database is created on a device.
  // This defines the actual table structure.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        assignee TEXT,
        deadline TEXT NOT NULL,
        priority TEXT,
        isCompleted INTEGER NOT NULL
      )
    ''');
  }

  // CREATE: saves a new task, returns the id sqflite assigned it
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  // READ: gets every task currently saved
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // UPDATE: saves changes to a task that already exists
  // (matches by id, so the task must already have one)
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // DELETE: removes a task permanently
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
