import '../../../../core/reminders/reminder_lead_time_preset.dart';
import 'task_category.dart';
import 'task_checklist_item.dart';
import 'task_quadrant.dart';
import 'task_status.dart';

const Object _taskUnset = Object();

class Task {
  Task({
    required this.id,
    required this.title,
    required this.date,
    this.startTime,
    this.durationMinutes,
    this.deadline,
    this.reminderPreset = ReminderLeadTimePreset.none,
    this.reminderAt,
    this.isUrgent = false,
    this.isImportant = false,
    List<TaskChecklistItem> subtasks = const <TaskChecklistItem>[],
    this.status = TaskStatus.pending,
    this.category = TaskCategory.other,
    this.isAllDay = false,
    required this.createdAt,
    required this.updatedAt,
    this.evaluationTime,
  }) : assert(
         !isAllDay || (startTime == null && durationMinutes == null),
         'All-day tasks cannot have start time or duration.',
       ),
       subtasks = List<TaskChecklistItem>.unmodifiable(subtasks),
       assert(
         deadline == null ||
             reminderAt == null ||
             !reminderAt.isAfter(deadline),
         'Reminder cannot be after deadline.',
       );

  final String id;
  final String title;
  final DateTime date;
  final DateTime? startTime;
  final int? durationMinutes;
  final DateTime? deadline;
  final ReminderLeadTimePreset reminderPreset;
  final DateTime? reminderAt;
  final bool isUrgent;
  final bool isImportant;
  final List<TaskChecklistItem> subtasks;
  final TaskStatus status;
  final TaskCategory category;
  final bool isAllDay;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? evaluationTime;

  bool get isCompleted => status == TaskStatus.completed;
  bool get isOverdue => isOverdueAt(reference: evaluationTime);
  bool get hasReminderPreset => reminderPreset.hasReminder;
  bool get hasIncompleteSubtasks =>
      subtasks.any((TaskChecklistItem item) => !item.isCompleted);
  TaskQuadrant get quadrant =>
      TaskQuadrant.fromFlags(isUrgent: isUrgent, isImportant: isImportant);
  int get totalSubtaskCount => subtasks.length;
  int get completedSubtaskCount =>
      subtasks.where((TaskChecklistItem item) => item.isCompleted).length;

  DateTime? get endTime {
    final DateTime? start = startTime;
    final int? duration = durationMinutes;
    if (start == null || duration == null) {
      return null;
    }

    return start.add(Duration(minutes: duration));
  }

  DateTime? get reminderAnchor {
    if (deadline != null) {
      return deadline;
    }
    if (startTime != null) {
      return startTime;
    }
    if (isAllDay) {
      return DateTime(date.year, date.month, date.day);
    }

    return null;
  }

  DateTime? get resolvedReminderAt {
    return reminderPreset.resolveReminderAt(reminderAnchor);
  }

  bool get hasPendingReminderConfiguration {
    return hasReminderPreset && resolvedReminderAt == null;
  }

  DateTime get overdueCutoff {
    return deadline ?? DateTime(date.year, date.month, date.day + 1);
  }

  bool isOverdueAt({DateTime? reference}) {
    if (isCompleted) {
      return false;
    }

    final DateTime resolvedReference = reference ?? DateTime.now();
    return !resolvedReference.isBefore(overdueCutoff);
  }

  Task withResolvedReminderSchedule() {
    final DateTime? nextReminderAt = resolvedReminderAt;
    if (nextReminderAt == reminderAt) {
      return this;
    }

    return copyWith(reminderAt: nextReminderAt);
  }

  Task normalizedForPersistence() {
    final DateTime? normalizedReminderAt = resolvedReminderAt;
    final List<TaskChecklistItem> normalizedSubtasks = _normalizeSubtasks(
      subtasks,
    );

    if (normalizedReminderAt == reminderAt &&
        evaluationTime == null &&
        _subtasksEqual(normalizedSubtasks, subtasks)) {
      return this;
    }

    return copyWith(
      reminderAt: normalizedReminderAt,
      subtasks: normalizedSubtasks,
      evaluationTime: null,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    DateTime? date,
    Object? startTime = _taskUnset,
    Object? durationMinutes = _taskUnset,
    Object? deadline = _taskUnset,
    ReminderLeadTimePreset? reminderPreset,
    Object? reminderAt = _taskUnset,
    bool? isUrgent,
    bool? isImportant,
    Object? subtasks = _taskUnset,
    TaskStatus? status,
    TaskCategory? category,
    bool? isAllDay,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? evaluationTime = _taskUnset,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: identical(startTime, _taskUnset)
          ? this.startTime
          : startTime as DateTime?,
      durationMinutes: identical(durationMinutes, _taskUnset)
          ? this.durationMinutes
          : durationMinutes as int?,
      deadline: identical(deadline, _taskUnset)
          ? this.deadline
          : deadline as DateTime?,
      reminderPreset: reminderPreset ?? this.reminderPreset,
      reminderAt: identical(reminderAt, _taskUnset)
          ? this.reminderAt
          : reminderAt as DateTime?,
      isUrgent: isUrgent ?? this.isUrgent,
      isImportant: isImportant ?? this.isImportant,
      subtasks: identical(subtasks, _taskUnset)
          ? this.subtasks
          : List<TaskChecklistItem>.unmodifiable(
              subtasks as List<TaskChecklistItem>,
            ),
      status: status ?? this.status,
      category: category ?? this.category,
      isAllDay: isAllDay ?? this.isAllDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      evaluationTime: identical(evaluationTime, _taskUnset)
          ? this.evaluationTime
          : evaluationTime as DateTime?,
    );
  }

  static List<TaskChecklistItem> _normalizeSubtasks(
    List<TaskChecklistItem> items,
  ) {
    final List<TaskChecklistItem> normalized =
        items
            .map(
              (TaskChecklistItem item) =>
                  item.copyWith(title: item.normalizedTitle),
            )
            .where((TaskChecklistItem item) => item.hasContent)
            .toList(growable: false)
          ..sort(
            (TaskChecklistItem left, TaskChecklistItem right) =>
                left.sortOrder.compareTo(right.sortOrder),
          );

    return List<TaskChecklistItem>.unmodifiable(
      normalized.asMap().entries.map((MapEntry<int, TaskChecklistItem> entry) {
        return entry.value.copyWith(sortOrder: entry.key);
      }),
    );
  }

  static bool _subtasksEqual(
    List<TaskChecklistItem> left,
    List<TaskChecklistItem> right,
  ) {
    if (left.length != right.length) {
      return false;
    }

    for (int index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) {
        return false;
      }
    }

    return true;
  }
}
