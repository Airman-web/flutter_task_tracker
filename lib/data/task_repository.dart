import 'package:flutter/foundation.dart';
import '../models/task.dart';
import 'sample_tasks.dart';

/// Single source of truth for tasks (temporary in-memory version).
/// Persistence gets plugged in here later.
class TaskRepository extends ChangeNotifier {
  TaskRepository._();
  static final TaskRepository instance = TaskRepository._();

  final List<Task> _tasks = List.of(sampleTasks);
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Insert if the id is new, otherwise update.
  Future<void> save(Task task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) {
      _tasks.add(task);
    } else {
      _tasks[i] = task;
    }
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
