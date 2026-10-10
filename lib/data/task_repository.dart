import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/database_helper.dart';
import 'sample_tasks.dart';

/// Single source of truth for tasks.
/// Tasks are saved in a local sqflite database (see DatabaseHelper), so they
/// survive closing the app. The in-memory list is a copy that screens read.
class TaskRepository extends ChangeNotifier {
  TaskRepository._();
  static final TaskRepository instance = TaskRepository._();

  final List<Task> _tasks = [];
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Loads every saved task from the database. Called once at app start.
  Future<void> load() async {
  final database = DatabaseHelper.instance;

  var saved = await database.getAllTasks();

  // Add sample tasks only when the database is empty.
  if (saved.isEmpty) {
    for (final task in sampleTasks) {
      await database.insertTask(task);
    }

    saved = await database.getAllTasks();
  }

  _tasks
    ..clear()
    ..addAll(saved);

  _sortByDueDate();
  notifyListeners();
}

  /// Insert if the id is new, otherwise update.
  Future<void> save(Task task) async {
    // Write to the database first. If this throws, the form shows its
    // "Could not save" message and the list stays unchanged.
    // insertTask replaces a row with the same id, so it covers both cases.
    await DatabaseHelper.instance.insertTask(task);

    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) {
      _tasks.add(task);
    } else {
      _tasks[i] = task;
    }
    _sortByDueDate();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void _sortByDueDate() {
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}