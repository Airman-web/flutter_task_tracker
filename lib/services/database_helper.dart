import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import '../models/team_member.dart';

class DatabaseHelper {
  // Singleton: the whole app shares one database connection.
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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Runs the first time the database file is created on a device.
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

    await db.execute('''
      CREATE TABLE team_members(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE COLLATE NOCASE,
        passwordHash TEXT NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');
  }

  // Runs when the database version is increased.
  // Add new tables or columns here without losing existing data.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS team_members(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          role TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE COLLATE NOCASE,
          passwordHash TEXT NOT NULL,
          colorValue INTEGER NOT NULL
        )
      ''');
    }
  }

  // Generates a unique ID for a new task.
  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // Converts a Task object into a map for SQLite.
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

  // Converts a SQLite map into a Task object.
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

  // CREATE: saves a task, replacing it if the same ID already exists.
  Future<void> insertTask(Task task) async {
    final db = await database;

    await db.insert(
      'tasks',
      _toMap(task),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ: retrieves all tasks, ordered by due date.
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'dueDate ASC');

    return rows.map(_fromMap).toList();
  }

  // UPDATE: saves changes to an existing task.
  Future<int> updateTask(Task task) async {
    final db = await database;

    return db.update(
      'tasks',
      _toMap(task),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // DELETE: permanently removes a task.
  Future<int> deleteTask(String id) async {
    final db = await database;

    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Hashes a password before it is stored in the database.
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // CREATE: registers a team member with a password hash.
  Future<void> insertTeamMember({
    required TeamMember member,
    required String password,
  }) async {
    final db = await database;

    await db.insert('team_members', {
      'id': member.id,
      'name': member.name,
      'role': member.role,
      'email': member.email.trim().toLowerCase(),
      'passwordHash': hashPassword(password),
      'colorValue': member.color.toARGB32(),
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  // READ: retrieves all registered team members.
  Future<List<Map<String, Object?>>> getAllTeamMembers() async {
    final db = await database;

    return db.query('team_members', orderBy: 'name COLLATE NOCASE ASC');
  }

  // READ: finds a registered team member by email.
  Future<Map<String, Object?>?> getTeamMemberByEmail(String email) async {
    final db = await database;

    final rows = await db.query(
      'team_members',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    return rows.isEmpty ? null : rows.first;
  }

  // UPDATE: modifies a registered team member's details.
  Future<int> updateTeamMember(TeamMember member) async {
    final db = await database;

    return db.update(
      'team_members',
      {
        'name': member.name.trim(),
        'role': member.role.trim(),
        'email': member.email.trim().toLowerCase(),
        'colorValue': member.color.toARGB32(),
      },
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  // DELETE: removes a registered team member.
  Future<int> deleteTeamMember(String id) async {
    final db = await database;

    return db.delete('team_members', where: 'id = ?', whereArgs: [id]);
  }

  // Checks whether a password matches its saved hash.
  bool verifyPassword(String password, String savedHash) {
    return hashPassword(password) == savedHash;
  }
}
