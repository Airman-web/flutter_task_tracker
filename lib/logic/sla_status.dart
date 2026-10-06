import '../models/task.dart';

enum SlaStatus { onTrack, atRisk, overdue, completed }

extension SlaStatusLabel on SlaStatus {
  String get label {
    switch (this) {
      case SlaStatus.onTrack:
        return 'On Track';
      case SlaStatus.atRisk:
        return 'At Risk';
      case SlaStatus.overdue:
        return 'Overdue';
      case SlaStatus.completed:
        return 'Completed';
    }
  }
}

SlaStatus classifyTask(Task task, {DateTime? now}) {
  final currentDate = _dateOnly(now ?? DateTime.now());
  final deadlineDate = _dateOnly(task.dueDate);

  if (task.isCompleted) {
    return SlaStatus.completed;
  }

  if (deadlineDate.isBefore(currentDate)) {
    return SlaStatus.overdue;
  }

  final daysUntilDeadline = deadlineDate.difference(currentDate).inDays;
  if (daysUntilDeadline <= 2) {
    return SlaStatus.atRisk;
  }

  return SlaStatus.onTrack;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);