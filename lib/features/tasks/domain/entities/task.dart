import 'task_category.dart';
import 'task_priority.dart';
import 'task_status.dart';

const Object _taskUnset = Object();

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.durationMinutes,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.category = TaskCategory.other,
    this.isAllDay = false,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         !isAllDay || (startTime == null && durationMinutes == null),
         'All-day tasks cannot have start time or duration.',
       );

  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime? startTime;
  final int? durationMinutes;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskCategory category;
  final bool isAllDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == TaskStatus.completed;

  DateTime? get endTime {
    final DateTime? start = startTime;
    final int? duration = durationMinutes;
    if (start == null || duration == null) {
      return null;
    }

    return start.add(Duration(minutes: duration));
  }

  Task copyWith({
    String? id,
    String? title,
    Object? description = _taskUnset,
    DateTime? date,
    Object? startTime = _taskUnset,
    Object? durationMinutes = _taskUnset,
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
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      isAllDay: isAllDay ?? this.isAllDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
