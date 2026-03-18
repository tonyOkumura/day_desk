import 'package:isar/isar.dart';

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
      priority: priority,
      status: status,
      category: category,
      isAllDay: isAllDay,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static TaskLocalModel fromEntity(Task task, {Id? isarId}) {
    return TaskLocalModel()
      ..isarId = isarId ?? Isar.autoIncrement
      ..taskId = task.id
      ..title = task.title
      ..description = task.description
      ..date = task.date
      ..startTime = task.startTime
      ..durationMinutes = task.durationMinutes
      ..priority = task.priority
      ..status = task.status
      ..category = task.category
      ..isAllDay = task.isAllDay
      ..createdAt = task.createdAt
      ..updatedAt = task.updatedAt;
  }
}
