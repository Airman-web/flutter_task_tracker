import '../logic/sla_status.dart';
import '../models/task.dart';

final List<Task> sampleTasks = [
  Task(
    id: '1',
    title: 'Design Login Screen',
    description: 'Create a clean login and onboarding flow.',
    assignee: 'Sarah Lee',
    dueDate: DateTime(2026, 10, 8),
    priority: TaskPriority.high,
    isCompleted: false,
    createdAt: DateTime(2026, 10, 2),
  ),
  Task(
    id: '2',
    title: 'Implement Local Storage',
    description: 'Persist tasks safely on the device.',
    assignee: 'David Chukwuebuka',
    dueDate: DateTime(2026, 10, 6),
    priority: TaskPriority.high,
    isCompleted: false,
    createdAt: DateTime(2026, 10, 1),
  ),
  Task(
    id: '3',
    title: 'Create Task Model',
    description: 'Define shared task fields and types.',
    assignee: 'John Doe',
    dueDate: DateTime(2026, 10, 10),
    priority: TaskPriority.medium,
    isCompleted: true,
    createdAt: DateTime(2026, 10, 3),
  ),
  Task(
    id: '4',
    title: 'Prepare Demo Notes',
    description: 'Prepare team explanation for the final review.',
    assignee: 'Emily Wang',
    dueDate: DateTime(2026, 10, 12),
    priority: TaskPriority.low,
    isCompleted: false,
    createdAt: DateTime(2026, 10, 4),
  ),
  Task(
    id: '5',
    title: 'QA Testing',
    description: 'Check task status and the dashboard layout.',
    assignee: 'Michael Kim',
    dueDate: DateTime(2026, 10, 4),
    priority: TaskPriority.medium,
    isCompleted: false,
    createdAt: DateTime(2026, 10, 5),
  ),
];

Color statusColor(SlaStatus status) {
  switch (status) {
    case SlaStatus.onTrack:
      return const Color(0xFF2ABF7D);
    case SlaStatus.atRisk:
      return const Color(0xFFF0B04F);
    case SlaStatus.overdue:
      return const Color(0xFFE16161);
    case SlaStatus.completed:
      return const Color(0xFF4C96F0);
  }
}

String formatTaskDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

String initialsFromName(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.isEmpty) return 'T';
  if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
  return '${words[0][0]}${words[1][0]}'.toUpperCase();
}
