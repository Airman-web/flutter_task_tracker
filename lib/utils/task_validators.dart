class TaskValidators {
  static const int titleMin = 3;
  static const int titleMax = 60;
  static const int descriptionMax = 300;

  static String? title(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Title is required';
    if (v.length < titleMin) return 'Title must be at least $titleMin characters';
    if (v.length > titleMax) return 'Title must be $titleMax characters or fewer';
    return null;
  }

  static String? description(String? value) {
    if ((value?.length ?? 0) > descriptionMax) {
      return 'Description must be $descriptionMax characters or fewer';
    }
    return null; // optional field
  }

  static String? assignee(String? value) =>
      (value == null || value.isEmpty) ? 'Please assign the task to someone' : null;

  /// A new task can't have a past deadline. When EDITING, an unchanged
  /// (already past) deadline is allowed, otherwise overdue tasks could
  /// never be edited at all.
  static String? deadline(DateTime? value, {DateTime? originalDeadline}) {
    if (value == null) return 'Please pick a deadline';
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final picked = DateTime(value.year, value.month, value.day);
    final unchanged = originalDeadline != null &&
        picked == DateTime(originalDeadline.year, originalDeadline.month, originalDeadline.day);
    if (picked.isBefore(startOfToday) && !unchanged) {
      return 'Deadline cannot be in the past';
    }
    return null;
  }
}