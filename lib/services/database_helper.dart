import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class DatabaseHelper {
  // Singleton: the whole app shares one database connection
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'task_tracker.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Runs the first time the database file is created on a device
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        assignee TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        priority TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // Version 1 of this table used an integer id and different column names.
  // No real data was stored in it, so we rebuild the table.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS tasks');
    await _onCreate(db, newVersion);
  }

  // The Task model uses a String id, so whoever creates a new task
  // (the Create/Edit form) can call this to get a unique one.
  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // sqflite only stores basic types, so we convert the Task here.
  // This keeps the shared Task model file untouched.
  Map<String, Object?> _toMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'assignee': task.assignee,
      'dueDate': task.dueDate.toIso8601String(),
      'priority': task.priority.name,
      'isCompleted': task.isCompleted ? 1 : 0,
      'createdAt': task.createdAt.toIso8601String(),
    };
  }

  Task _fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      assignee: map['assignee'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      priority: TaskPriority.values.byName(map['priority'] as String),
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // CREATE: saves a task (replaces it if the same id already exists)
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      _toMap(task),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ: every saved task, soonest due date first
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'dueDate ASC');
    return rows.map(_fromMap).toList();
  }

  // UPDATE: saves changes to an existing task, matched by id
  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.update(
      'tasks',
      _toMap(task),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // DELETE: removes a task permanently
  Future<int> deleteTask(String id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
