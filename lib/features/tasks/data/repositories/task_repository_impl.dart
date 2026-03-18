import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_local_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._localDataSource, {DateTime Function()? nowProvider})
    : _nowProvider = nowProvider ?? DateTime.now;

  final TaskLocalDataSource _localDataSource;
  final DateTime Function() _nowProvider;

  @override
  Future<void> createTask(Task task) async {
    final TaskLocalModel? existing = await _localDataSource.readTaskByTaskId(
      task.id,
    );
    if (existing != null) {
      throw StateError('Task with id "${task.id}" already exists.');
    }

    await _localDataSource.createTask(
      TaskLocalModel.fromEntity(task.normalizedForPersistence()),
    );
  }

  @override
  Future<void> updateTask(Task task) async {
    final TaskLocalModel? existing = await _localDataSource.readTaskByTaskId(
      task.id,
    );
    if (existing == null) {
      throw StateError('Task with id "${task.id}" was not found.');
    }

    await _localDataSource.updateTask(
      TaskLocalModel.fromEntity(
        task.normalizedForPersistence(),
        isarId: existing.isarId,
      ),
    );
  }

  @override
  Future<void> deleteTask(String taskId) {
    return _localDataSource.deleteTask(taskId);
  }

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final List<Task> tasks = await getAllTasks();
    return _filterTasksByDay(tasks, date);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final List<TaskLocalModel> tasks = await _localDataSource.readAllTasks();
    return tasks
        .map((TaskLocalModel task) => _materializeTask(task.toEntity()))
        .toList();
  }

  @override
  Stream<List<Task>> watchTasksByDate(DateTime date) {
    return watchAllTasks().map((List<Task> tasks) {
      return _filterTasksByDay(tasks, date);
    });
  }

  @override
  Stream<List<Task>> watchAllTasks() {
    return _localDataSource.watchAllTasks().map((List<TaskLocalModel> tasks) {
      return tasks
          .map((TaskLocalModel task) => _materializeTask(task.toEntity()))
          .toList();
    });
  }

  @override
  Future<void> markTaskCompleted(
    String taskId, {
    required bool completed,
  }) async {
    final Task existing = await _requireStoredTask(taskId);

    await updateTask(
      existing.copyWith(
        status: completed ? TaskStatus.completed : TaskStatus.pending,
        updatedAt: _nowProvider(),
      ),
    );
  }

  @override
  Future<void> setTaskPostponed(
    String taskId, {
    required bool postponed,
  }) async {
    final Task existing = await _requireStoredTask(taskId);

    await updateTask(
      existing.copyWith(
        status: postponed ? TaskStatus.postponed : TaskStatus.pending,
        updatedAt: _nowProvider(),
      ),
    );
  }

  @override
  Future<void> rescheduleTask(
    String taskId, {
    required DateTime date,
    DateTime? startTime,
  }) async {
    final Task existing = await _requireStoredTask(taskId);
    final DateTime normalizedDate = _startOfDay(date);
    final DateTime? nextDeadline = _resolveRescheduledDateTime(
      currentDateTime: existing.deadline,
      nextDate: normalizedDate,
    );

    final DateTime? nextStartTime = existing.isAllDay
        ? null
        : _resolveRescheduledStartTime(
            currentStartTime: existing.startTime,
            nextDate: normalizedDate,
            explicitStartTime: startTime,
          );

    await updateTask(
      existing.copyWith(
        date: normalizedDate,
        startTime: nextStartTime,
        deadline: nextDeadline,
        durationMinutes: existing.isAllDay ? null : existing.durationMinutes,
        updatedAt: _nowProvider(),
      ),
    );
  }

  Future<Task> _requireStoredTask(String taskId) async {
    final TaskLocalModel? task = await _localDataSource.readTaskByTaskId(
      taskId,
    );
    if (task == null) {
      throw StateError('Task with id "$taskId" was not found.');
    }

    return task.toEntity();
  }

  Task _materializeTask(Task task) {
    return task.withResolvedReminderSchedule().withEffectiveStatus(
      reference: _nowProvider(),
    );
  }

  List<Task> _filterTasksByDay(List<Task> tasks, DateTime date) {
    final DateTime dayStart = _startOfDay(date);
    final DateTime nextDayStart = dayStart.add(const Duration(days: 1));

    return tasks
        .where((Task task) {
          return !task.date.isBefore(dayStart) &&
              task.date.isBefore(nextDayStart);
        })
        .toList(growable: false);
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _resolveRescheduledStartTime({
    required DateTime? currentStartTime,
    required DateTime nextDate,
    required DateTime? explicitStartTime,
  }) {
    final DateTime? source = explicitStartTime ?? currentStartTime;
    if (source == null) {
      return null;
    }

    return DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      source.hour,
      source.minute,
      source.second,
      source.millisecond,
      source.microsecond,
    );
  }

  DateTime? _resolveRescheduledDateTime({
    required DateTime? currentDateTime,
    required DateTime nextDate,
  }) {
    if (currentDateTime == null) {
      return null;
    }

    return DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      currentDateTime.hour,
      currentDateTime.minute,
      currentDateTime.second,
      currentDateTime.millisecond,
      currentDateTime.microsecond,
    );
  }
}
