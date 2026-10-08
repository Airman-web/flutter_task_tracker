import '../models/task.dart';
import 'sla_status.dart';

class DashboardMetrics {
  DashboardMetrics.fromTasks(Iterable<Task> tasks, {DateTime? now}) {
    final counts = <SlaStatus, int>{
      for (final status in SlaStatus.values) status: 0,
    };
    final currentDate = now ?? DateTime.now();

    for (final task in tasks) {
      final status = classifyTask(task, now: currentDate);
      counts[status] = counts[status]! + 1;
    }

    statusCounts = counts;
    totalTasks = tasks.length;
    completedTasks = counts[SlaStatus.completed]!;
  }

  late final Map<SlaStatus, int> statusCounts;
  late final int totalTasks;
  late final int completedTasks;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;
}
