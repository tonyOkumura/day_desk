import '../../../../core/reminders/reminder_lead_time_preset.dart';
import 'task_category.dart';
import 'task_priority.dart';
import 'task_status.dart';

const Object _taskUnset = Object();

class Task {
  Task({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.durationMinutes,
    this.deadline,
    this.reminderPreset = ReminderLeadTimePreset.none,
    this.reminderAt,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.category = TaskCategory.other,
    this.isAllDay = false,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         !isAllDay || (startTime == null && durationMinutes == null),
         'All-day tasks cannot have start time or duration.',
       ),
       assert(
         deadline == null ||
             reminderAt == null ||
             !reminderAt.isAfter(deadline),
         'Reminder cannot be after deadline.',
       );

  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime? startTime;
  final int? durationMinutes;
  final DateTime? deadline;
  final ReminderLeadTimePreset reminderPreset;
  final DateTime? reminderAt;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskCategory category;
  final bool isAllDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == TaskStatus.completed;
  bool get isPostponed => status == TaskStatus.postponed;
  bool get isOverdue => status == TaskStatus.overdue;
  bool get hasReminderPreset => reminderPreset.hasReminder;

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
    if (status != TaskStatus.pending) {
      return false;
    }

    final DateTime resolvedReference = reference ?? DateTime.now();
    return !resolvedReference.isBefore(overdueCutoff);
  }

  TaskStatus resolveEffectiveStatus({DateTime? reference}) {
    if (status != TaskStatus.pending) {
      return status;
    }

    return isOverdueAt(reference: reference)
        ? TaskStatus.overdue
        : TaskStatus.pending;
  }

  Task withEffectiveStatus({DateTime? reference}) {
    final TaskStatus effectiveStatus = resolveEffectiveStatus(
      reference: reference,
    );
    if (effectiveStatus == status) {
      return this;
    }

    return copyWith(status: effectiveStatus);
  }

  Task withResolvedReminderSchedule() {
    final DateTime? nextReminderAt = resolvedReminderAt;
    if (nextReminderAt == reminderAt) {
      return this;
    }

    return copyWith(reminderAt: nextReminderAt);
  }

  Task normalizedForPersistence() {
    final TaskStatus normalizedStatus = status == TaskStatus.overdue
        ? TaskStatus.pending
        : status;
    final DateTime? normalizedReminderAt = resolvedReminderAt;

    if (normalizedStatus == status && normalizedReminderAt == reminderAt) {
      return this;
    }

    return copyWith(status: normalizedStatus, reminderAt: normalizedReminderAt);
  }

  Task copyWith({
    String? id,
    String? title,
    Object? description = _taskUnset,
    DateTime? date,
    Object? startTime = _taskUnset,
    Object? durationMinutes = _taskUnset,
    Object? deadline = _taskUnset,
    ReminderLeadTimePreset? reminderPreset,
    Object? reminderAt = _taskUnset,
    TaskPriority? priority,
    TaskStatus? status,
    TaskCategory? category,
    bool? isAllDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: identical(description, _taskUnset)
          ? this.description
          : description as String?,
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
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      isAllDay: isAllDay ?? this.isAllDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
