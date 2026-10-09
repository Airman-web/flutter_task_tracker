import 'package:flutter/material.dart';
import '../data/task_repository.dart';
import '../models/task.dart';
import '../utils/task_validators.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task}); // null = create, non-null = edit
  final Task? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  // Identifies the Form so we can call validate() on all its fields at once
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  String? _assignee;
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  // TEMP: replace with TeamRepository.instance.members after merge
  static const _stubMembers = [
    'John Doe', 'Sarah Lee', 'Michael Kim', 'Emily Wong', 'David Liu',
  ];

  List<String> get _memberNames {
    final names = List<String>.of(_stubMembers);
    final current = widget.task?.assignee;
    // keep the existing assignee selectable even if not in the team list
    if (current != null && !names.contains(current)) names.insert(0, current);
    return names;
  }

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _assignee = t?.assignee;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Runs every field's validator; shows error text and stops if any fail
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final task = Task(
        id: widget.task?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        assignee: _assignee!,
        // TEMP (Step 4 replaces both of these)
        dueDate: widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 7)),
        priority: widget.task?.priority ?? TaskPriority.medium,
        isCompleted: widget.task?.isCompleted ?? false,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
      );
      await TaskRepository.instance.save(task);
      if (!mounted) return;
      Navigator.pop(context, task); // hand the saved task back to the caller
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the task. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'New Task')),
      body: Form(
        key: _formKey,
        child: ListView( // scrolls when the keyboard is open
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              maxLength: TaskValidators.titleMax,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: TaskValidators.title,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              maxLength: TaskValidators.descriptionMax,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator: TaskValidators.description,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _assignee,
              decoration: const InputDecoration(
                labelText: 'Assignee *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: _memberNames
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: (v) => setState(() => _assignee = v),
              validator: TaskValidators.assignee,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_isEditing ? 'Save Changes' : 'Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}