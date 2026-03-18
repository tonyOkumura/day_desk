import 'package:isar/isar.dart';

import '../../../../core/reminders/reminder_lead_time_preset.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_checklist_item.dart';
import '../../domain/entities/task_status.dart';

part 'task_local_model.g.dart';

@embedded
class TaskChecklistItemLocalModel {
  TaskChecklistItemLocalModel();

  late String itemId;
  late String title;
  bool isCompleted = false;
  int sortOrder = 0;

  TaskChecklistItem toEntity() {
    return TaskChecklistItem(
      id: itemId,
      title: title,
      isCompleted: isCompleted,
      sortOrder: sortOrder,
    );
  }

  static TaskChecklistItemLocalModel fromEntity(TaskChecklistItem item) {
    return TaskChecklistItemLocalModel()
      ..itemId = item.id
      ..title = item.title
      ..isCompleted = item.isCompleted
      ..sortOrder = item.sortOrder;
  }
}

@collection
class TaskLocalModel {
  TaskLocalModel();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String taskId;

  @Index()
  late DateTime date;

  late String title;

  DateTime? startTime;

  int? durationMinutes;

  DateTime? deadline;

  @Enumerated(EnumType.name)
  ReminderLeadTimePreset reminderPreset = ReminderLeadTimePreset.none;

  DateTime? reminderAt;

  bool isUrgent = false;

  bool isImportant = true;

  List<TaskChecklistItemLocalModel> subtasks = <TaskChecklistItemLocalModel>[];

  @Index()
  String status = 'pending';

  @Enumerated(EnumType.name)
  TaskCategory category = TaskCategory.other;

  bool isAllDay = false;

  late DateTime createdAt;

  late DateTime updatedAt;

  Task toEntity() {
    return Task(
      id: taskId,
      title: title,
      date: date,
      startTime: startTime,
      durationMinutes: durationMinutes,
      deadline: deadline,
      reminderPreset: reminderPreset,
      reminderAt: reminderAt,
      isUrgent: isUrgent,
      isImportant: isImportant,
      subtasks: subtasks
          .map((TaskChecklistItemLocalModel item) => item.toEntity())
          .toList(growable: false),
      status: _statusFromStorage(status),
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
      ..date = normalizedTask.date
      ..startTime = normalizedTask.startTime
      ..durationMinutes = normalizedTask.durationMinutes
      ..deadline = normalizedTask.deadline
      ..reminderPreset = normalizedTask.reminderPreset
      ..reminderAt = normalizedTask.reminderAt
      ..isUrgent = normalizedTask.isUrgent
      ..isImportant = normalizedTask.isImportant
      ..subtasks = normalizedTask.subtasks
          .map(TaskChecklistItemLocalModel.fromEntity)
          .toList(growable: false)
      ..status = normalizedTask.status.name
      ..category = normalizedTask.category
      ..isAllDay = normalizedTask.isAllDay
      ..createdAt = normalizedTask.createdAt
      ..updatedAt = normalizedTask.updatedAt;
  }

  static TaskStatus _statusFromStorage(String value) {
    return switch (value) {
      'completed' => TaskStatus.completed,
      'postponed' || 'overdue' || 'pending' => TaskStatus.pending,
      _ => TaskStatus.pending,
    };
  }
}
