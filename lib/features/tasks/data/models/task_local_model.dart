import 'package:isar/isar.dart';

import '../../../../core/reminders/reminder_lead_time_preset.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';

part 'task_local_model.g.dart';

@collection
class TaskLocalModel {
  TaskLocalModel();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String taskId;

  @Index()
  late DateTime date;

  late String title;

  String? description;

  DateTime? startTime;

  int? durationMinutes;

  DateTime? deadline;

  @Enumerated(EnumType.name)
  ReminderLeadTimePreset reminderPreset = ReminderLeadTimePreset.none;

  DateTime? reminderAt;

  @Enumerated(EnumType.name)
  TaskPriority priority = TaskPriority.medium;

  @Enumerated(EnumType.name)
  TaskStatus status = TaskStatus.pending;

  @Enumerated(EnumType.name)
  TaskCategory category = TaskCategory.other;

  bool isAllDay = false;

  late DateTime createdAt;

  late DateTime updatedAt;

  Task toEntity() {
    return Task(
      id: taskId,
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      durationMinutes: durationMinutes,
      deadline: deadline,
      reminderPreset: reminderPreset,
      reminderAt: reminderAt,
      priority: priority,
      status: status,
      category: category,
      isAllDay: isAllDay,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static TaskLocalModel fromEntity(Task task, {Id? isarId}) {
    final Task normalizedTask = task.normalizedForPersistence();
    return TaskLocalModel()
      ..isarId = isarId ?? Isar.autoIncrement
      ..taskId = normalizedTask.id
      ..title = normalizedTask.title
      ..description = normalizedTask.description
      ..date = normalizedTask.date
      ..startTime = normalizedTask.startTime
      ..durationMinutes = normalizedTask.durationMinutes
      ..deadline = normalizedTask.deadline
      ..reminderPreset = normalizedTask.reminderPreset
      ..reminderAt = normalizedTask.reminderAt
      ..priority = normalizedTask.priority
      ..status = normalizedTask.status
      ..category = normalizedTask.category
      ..isAllDay = normalizedTask.isAllDay
      ..createdAt = normalizedTask.createdAt
      ..updatedAt = normalizedTask.updatedAt;
  }
}
