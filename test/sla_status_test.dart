import 'package:flutter_task_tracker/logic/sla_status.dart';
import 'package:flutter_task_tracker/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final referenceDate = DateTime(2026, 10, 5, 12);

  Task createTask({required DateTime dueDate, bool isCompleted = false}) {
    return Task(
      id: 'task-1',
      title: 'Design dashboard',
      description: 'Create the project dashboard',
      assignee: 'David',
      dueDate: dueDate,
      priority: TaskPriority.high,
      isCompleted: isCompleted,
      createdAt: referenceDate,
    );
  }

  test('completed tasks remain completed even after their deadline', () {
    final task = createTask(
      dueDate: DateTime(2026, 10, 1),
      isCompleted: true,
    );

    expect(
      classifyTask(task, now: referenceDate),
      SlaStatus.completed,
    );
  });

  test('incomplete tasks with a past deadline are overdue', () {
    final task = createTask(dueDate: DateTime(2026, 10, 4));

    expect(classifyTask(task, now: referenceDate), SlaStatus.overdue);
  });

  test('tasks due today or within two days are at risk', () {
    expect(
      classifyTask(
        createTask(dueDate: DateTime(2026, 10, 5)),
        now: referenceDate,
      ),
      SlaStatus.atRisk,
    );
    expect(
      classifyTask(
        createTask(dueDate: DateTime(2026, 10, 7)),
        now: referenceDate,
      ),
      SlaStatus.atRisk,
    );
  });

  test('tasks due more than two days from now are on track', () {
    final task = createTask(dueDate: DateTime(2026, 10, 8));

    expect(classifyTask(task, now: referenceDate), SlaStatus.onTrack);
  });
}