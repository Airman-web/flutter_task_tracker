import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_task_tracker/logic/dashboard_metrics.dart';
import 'package:flutter_task_tracker/logic/sla_status.dart';
import 'package:flutter_task_tracker/models/task.dart';

void main() {
  final referenceDate = DateTime(2026, 10, 5, 12);

  Task createTask({required DateTime dueDate, bool isCompleted = false}) {
    return Task(
      id: dueDate.toIso8601String(),
      title: 'Task',
      description: 'Dashboard test task',
      assignee: 'David',
      dueDate: dueDate,
      priority: TaskPriority.medium,
      isCompleted: isCompleted,
      createdAt: referenceDate,
    );
  }

  test('calculates dashboard counts and progress from task statuses', () {
    final metrics = DashboardMetrics.fromTasks([
      createTask(dueDate: DateTime(2026, 10, 10)),
      createTask(dueDate: DateTime(2026, 10, 6)),
      createTask(dueDate: DateTime(2026, 10, 4)),
      createTask(dueDate: DateTime(2026, 10, 1), isCompleted: true),
    ], now: referenceDate);

    expect(metrics.totalTasks, 4);
    expect(metrics.statusCounts[SlaStatus.onTrack], 1);
    expect(metrics.statusCounts[SlaStatus.atRisk], 1);
    expect(metrics.statusCounts[SlaStatus.overdue], 1);
    expect(metrics.statusCounts[SlaStatus.completed], 1);
    expect(metrics.progress, 0.25);
  });

  test('returns zero progress for an empty task list', () {
    final metrics = DashboardMetrics.fromTasks([], now: referenceDate);

    expect(metrics.totalTasks, 0);
    expect(metrics.progress, 0);
  });
}
