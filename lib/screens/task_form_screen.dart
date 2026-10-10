import 'package:flutter/material.dart';
import '../data/sample_tasks.dart' show formatTaskDate;
import '../data/task_repository.dart';
import '../models/task.dart';
import '../utils/task_validators.dart';
import '../data/team_repository.dart';

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
  DateTime? _dueDate;
  late TaskPriority _priority;
  bool _isSaving = false;
  bool _dirty = false; // true once the user changes anything

  bool get _isEditing => widget.task != null;

// Returns a list of all team member names, plus the current assignee if editing an older task.
  List<String> get _memberNames {
  final names = TeamRepository.instance.members
      .map((member) => member.name)
      .toList();

  final current = widget.task?.assignee;

  // Keep the current assignee available when editing an older task.
  if (current != null && !names.contains(current)) {
    names.insert(0, current);
  }

  return names;
}

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _assignee = t?.assignee;
    _dueDate = t?.dueDate;
    _priority = t?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _markDirty() {
    // setState is required: PopScope.canPop is read during build()
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _pickDate(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final original = widget.task?.dueDate;
    // When editing an already-overdue task, its old date stays selectable
    final floor =
        (original != null && original.isBefore(today)) ? original : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: floor, // past dates are greyed out in the picker
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dirty = true;
      });
      field.didChange(picked); // tells the FormField so its error clears
    }
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes that will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep editing')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Discard')),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _save() async {
  FocusScope.of(context).unfocus(); // hide the keyboard so errors aren't covered
  if (!_formKey.currentState!.validate()) return;
   setState(() => _isSaving = true);
    try {
      final task = Task(
        id: widget.task?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        assignee: _assignee!,
        dueDate: _dueDate!, // safe: validate() already blocked a null date
        priority: _priority,
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
    return PopScope(
      canPop: !_dirty, // back is blocked while there are unsaved changes
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (await _confirmDiscard()) nav.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'New Task')),
        body: Form(
          key: _formKey,
          onChanged: _markDirty,
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
              const SizedBox(height: 16),
              // FormField wrapper gives the date picker validation + inline error
              FormField<DateTime>(
                initialValue: _dueDate,
                validator: (v) => TaskValidators.deadline(
                  v,
                  originalDeadline: widget.task?.dueDate,
                ),
                builder: (field) => InkWell(
                  onTap: () => _pickDate(field),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Deadline *',
                      prefixIcon: const Icon(Icons.event),
                      border: const OutlineInputBorder(),
                      errorText: field.errorText,
                    ),
                    child: Text(
                      _dueDate == null
                          ? 'Tap to pick a date'
                          : formatTaskDate(_dueDate!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Priority', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: const [
                  ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                  ButtonSegment(value: TaskPriority.medium, label: Text('Medium')),
                  ButtonSegment(value: TaskPriority.high, label: Text('High')),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() {
                  _priority = s.first;
                  _dirty = true;
                }),
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
      ),
    );
  }
}