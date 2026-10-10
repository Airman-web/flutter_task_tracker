
import 'package:flutter/material.dart';
import 'task_form_screen.dart';
import '../data/task_repository.dart';
import '../logic/sla_status.dart';
import '../models/task.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task});

  final Task task;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  bool _isSaving = false;

  final TaskRepository _repository = TaskRepository.instance;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _toggleCompletion() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final updatedTask = _task.copyWith(
      isCompleted: !_task.isCompleted,
    );

    try {
      await _repository.save(updatedTask);

      if (!mounted) return;

      setState(() {
        _task = updatedTask;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedTask.isCompleted
                ? 'Task marked as completed.'
                : 'Task marked as incomplete.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update the task. Please try again.'),
        ),
      );
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
          'Are you sure you want to delete "${_task.title}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _repository.delete(_task.id);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete the task. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = classifyTask(_task);
    final badgeColor = statusColor(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2430),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Edit task',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _isSaving
                ? null
                : () async {
                    final updatedTask = await Navigator.push<Task>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskFormScreen(task: _task),
                      ),
                    );

                    if (!mounted || updatedTask == null) return;

                    setState(() {
                      _task = updatedTask;
                    });
                  },
          ),
          IconButton(
            tooltip: 'Delete task',
            onPressed: _isSaving ? null : _deleteTask,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _task.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2430),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _task.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5C6471),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Assigned to', value: _task.assignee),
            _DetailRow(
              label: 'Deadline',
              value: formatTaskDate(_task.dueDate),
            ),
            _DetailRow(
              label: 'Priority',
              value: _task.priority.name.toUpperCase(),
            ),
            _DetailRow(
              label: 'Status',
              value: status.label,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _toggleCompletion,
                icon: Icon(
                  _task.isCompleted
                      ? Icons.undo
                      : Icons.check_circle_outline,
                ),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : _task.isCompleted
                          ? 'Mark as Incomplete'
                          : 'Mark as Complete',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5C6471),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2430),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


String formatTaskDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
