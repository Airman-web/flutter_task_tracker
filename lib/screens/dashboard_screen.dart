import 'package:flutter/material.dart';
import 'package:flutter_task_tracker/logic/sla_status.dart';
import 'package:flutter_task_tracker/models/task.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Task> get _tasks => widget.tasks;

  Map<SlaStatus, int> get _statusCounts {
    final counts = {
      SlaStatus.onTrack: 0,
      SlaStatus.atRisk: 0,
      SlaStatus.overdue: 0,
      SlaStatus.completed: 0,
    };

    for (final task in _tasks) {
      final status = classifyTask(task, now: DateTime(2026, 10, 5, 12));
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final statusCounts = _statusCounts;
    final totalTasks = _tasks.length;
    final completedTasks = statusCounts[SlaStatus.completed] ?? 0;
    final progressValue = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFE3EEF9),
                    child: Icon(
                      Icons.people_alt_rounded,
                      color: Color(0xFF2B5FD9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Good morning,',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5C6471),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'John',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.search, color: Color(0xFF6E7788)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Here\'s what\'s happening with your project.',
                style: TextStyle(fontSize: 14, color: Color(0xFF5C6471)),
              ),
              const SizedBox(height: 18),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _SummaryCard(
                    label: 'Total Tasks',
                    value: totalTasks.toString(),
                    color: const Color(0xFFDDEAFB),
                    valueColor: const Color(0xFF1F2430),
                    icon: Icons.checklist_rounded,
                  ),
                  _SummaryCard(
                    label: 'On Track',
                    value: (statusCounts[SlaStatus.onTrack] ?? 0).toString(),
                    color: const Color(0xFFDDF6ED),
                    valueColor: const Color(0xFF1F2430),
                    icon: Icons.trending_up_rounded,
                  ),
                  _SummaryCard(
                    label: 'At Risk',
                    value: (statusCounts[SlaStatus.atRisk] ?? 0).toString(),
                    color: const Color(0xFFFFF0D8),
                    valueColor: const Color(0xFF1F2430),
                    icon: Icons.warning_amber_rounded,
                  ),
                  _SummaryCard(
                    label: 'Overdue',
                    value: (statusCounts[SlaStatus.overdue] ?? 0).toString(),
                    color: const Color(0xFFFDE4E4),
                    valueColor: const Color(0xFF1F2430),
                    icon: Icons.schedule_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Task Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                        Icon(Icons.more_horiz, color: Color(0xFF737E90)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 120,
                      child: Row(
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: progressValue,
                                    strokeWidth: 12,
                                    backgroundColor: const Color(0xFFEDEFF4),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF2C6EEA),
                                        ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(progressValue * 100).round()}%',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2430),
                                      ),
                                    ),
                                    const Text(
                                      'Complete',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6E7788),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _LegendRow(
                                  label: 'On Track',
                                  value: (statusCounts[SlaStatus.onTrack] ?? 0)
                                      .toString(),
                                  color: const Color(0xFF43C88B),
                                ),
                                const SizedBox(height: 8),
                                _LegendRow(
                                  label: 'At Risk',
                                  value: (statusCounts[SlaStatus.atRisk] ?? 0)
                                      .toString(),
                                  color: const Color(0xFFF4B460),
                                ),
                                const SizedBox(height: 8),
                                _LegendRow(
                                  label: 'Overdue',
                                  value: (statusCounts[SlaStatus.overdue] ?? 0)
                                      .toString(),
                                  color: const Color(0xFFE16161),
                                ),
                                const SizedBox(height: 8),
                                _LegendRow(
                                  label: 'Completed',
                                  value:
                                      (statusCounts[SlaStatus.completed] ?? 0)
                                          .toString(),
                                  color: const Color(0xFF7ABAF2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
              ),
              const SizedBox(height: 12),
              ..._tasks.map((task) {
                final status = classifyTask(
                  task,
                  now: DateTime(2026, 10, 5, 12),
                );
                final color = _statusColor(status);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE3EDF8),
                        child: Text(
                          task.assignee
                              .split(' ')
                              .map((e) => e[0])
                              .take(2)
                              .join(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B5FD9),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2430),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${task.assignee} • ${_formatDate(task.dueDate)}',
                              style: const TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status.label,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _NavItem(icon: Icons.home_rounded, active: true),
            _NavItem(icon: Icons.list_alt_rounded),
            _NavItem(icon: Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Color _statusColor(SlaStatus status) {
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

  String _formatDate(DateTime date) {
    final month = date.month;
    final day = date.day;
    return '$month/$day';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.valueColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: valueColor),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF415065),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF5C6471)),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1F2430),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, this.active = false});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: active ? const Color(0xFF2C6EEA) : const Color(0xFF6E7788),
      size: 28,
    );
  }
}
