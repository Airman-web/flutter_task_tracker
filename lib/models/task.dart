// Possible SLA statuses a task can have
enum SlaStatus { onTrack, atRisk, overdue, completed }

class Task {
  int? id; // null until sqflite assigns one on insert
  String title;
  String description;
  String assignee;
  DateTime deadline;
  String priority; // e.g. "Low", "Medium", "High"
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.assignee,
    required this.deadline,
    required this.priority,
    this.isCompleted = false,
  });

  // Converts a Task into a Map, which is what sqflite needs to save a row
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignee': assignee,
      'deadline': deadline.toIso8601String(), // sqflite has no DateTime type
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0, // sqflite has no bool type
    };
  }

  // Converts a Map (a row from the database) back into a Task object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      assignee: map['assignee'],
      deadline: DateTime.parse(map['deadline']),
      priority: map['priority'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // This is the SLA logic: decides the task's current status
  // based on its deadline and whether it's marked complete.
  SlaStatus get slaStatus {
    if (isCompleted) {
      return SlaStatus.completed;
    }

    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      // deadline has already passed and it's not completed
      return SlaStatus.overdue;
    } else if (difference.inDays <= 2) {
      // due within 2 days, our team's agreed "At Risk" rule
      return SlaStatus.atRisk;
    } else {
      return SlaStatus.onTrack;
    }
  }

  // Human-readable label for the status, used in the UI badge
  String get slaStatusLabel {
    switch (slaStatus) {
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
