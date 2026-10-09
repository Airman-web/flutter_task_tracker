import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _allTasks = [];
  bool _isLoading = true;

  // Which filter is selected: 'all', 'onTrack', 'atRisk', 'overdue', 'completed'
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Pulls every task from the database and refreshes the screen
  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await DatabaseHelper.instance.getAllTasks();
    // Soonest deadline first, so urgent tasks surface at the top
    tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    setState(() {
      _allTasks = tasks;
      _isLoading = false;
    });
  }

  // Only the tasks that match the current filter
  List<Task> get _visibleTasks {
    if (_filter == 'all') return _allTasks;
    return _allTasks.where((t) => t.slaStatus.name == _filter).toList();
  }

  // One color per SLA status, used on the badge
  Color _colorForStatus(SlaStatus status) {
    switch (status) {
      case SlaStatus.onTrack:
        return Colors.green;
      case SlaStatus.atRisk:
        return Colors.orange;
      case SlaStatus.overdue:
        return Colors.red;
      case SlaStatus.completed:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filter = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('All')),
              PopupMenuItem(value: 'onTrack', child: Text('On Track')),
              PopupMenuItem(value: 'atRisk', child: Text('At Risk')),
              PopupMenuItem(value: 'overdue', child: Text('Overdue')),
              PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _visibleTasks.isEmpty
              ? const Center(child: Text('No tasks yet.'))
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    itemCount: _visibleTasks.length,
                    itemBuilder: (context, index) {
                      final task = _visibleTasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(
                            'Assigned to ${task.assignee} | Due ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _colorForStatus(task.slaStatus),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.slaStatusLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Opening Task Details gets wired in once that
                          // screen exists and navigation is merged
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}