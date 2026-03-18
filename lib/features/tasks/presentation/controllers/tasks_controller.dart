import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/notifications/app_notification_service.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_list_options.dart';

class TasksController extends GetxController {
  TasksController({
    required TaskRepository repository,
    required AppDateFormatter dateFormatter,
    required AppLogger logger,
    required AppNotificationService notificationService,
  }) : _repository = repository,
       _dateFormatter = dateFormatter,
       _logger = logger,
       _notificationService = notificationService,
       _selectedDate = dateFormatter.startOfDay(DateTime.now()).obs;

  final TaskRepository _repository;
  final AppDateFormatter _dateFormatter;
  final AppLogger _logger;
  final AppNotificationService _notificationService;

  final RxList<Task> _tasks = <Task>[].obs;
  final RxBool _loading = true.obs;
  final RxnString _errorMessage = RxnString();
  final Rx<TaskListMode> _listMode = TaskListMode.forDay.obs;
  final Rx<DateTime> _selectedDate;
  final Rx<TaskStatusFilter> _statusFilter = TaskStatusFilter.all.obs;
  final Rx<TaskSortOption> _sortOption = TaskSortOption.chronological.obs;

  StreamSubscription<List<Task>>? _subscription;

  List<TaskListMode> get listModes => TaskListMode.values;
  List<TaskStatusFilter> get statusFilters => TaskStatusFilter.values;
  List<TaskSortOption> get sortOptions => TaskSortOption.values;
  TaskListMode get listMode => _listMode.value;
  DateTime get selectedDate => _selectedDate.value;
  TaskStatusFilter get statusFilter => _statusFilter.value;
  TaskSortOption get sortOption => _sortOption.value;
  bool get isLoading => _loading.value;
  String? get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value != null;
  bool get hasSourceTasks => _tasks.isNotEmpty;
  List<Task> get sourceTasks => _tasks.toList(growable: false);
  String get selectedDateLabel => _dateFormatter.formatFullDate(selectedDate);

  List<Task> get visibleTasks {
    final Iterable<Task> filtered = switch (statusFilter) {
      TaskStatusFilter.all => _tasks,
      TaskStatusFilter.pending => _tasks.where(
        (Task task) => task.status == TaskStatus.pending,
      ),
      TaskStatusFilter.completed => _tasks.where(
        (Task task) => task.status == TaskStatus.completed,
      ),
    };

    final List<Task> sorted = filtered.toList(growable: false);
    sorted.sort(_taskComparator);
    return sorted;
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(_bindTasks());
  }

  Future<void> selectListMode(TaskListMode mode) async {
    if (mode == listMode) {
      return;
    }

    _listMode.value = mode;
    await _bindTasks();
  }

  Future<void> selectDate(DateTime date) async {
    final DateTime normalizedDate = _dateFormatter.startOfDay(date);
    if (_dateFormatter.isSameDay(normalizedDate, selectedDate)) {
      return;
    }

    _selectedDate.value = normalizedDate;
    if (listMode == TaskListMode.forDay) {
      await _bindTasks();
    }
  }

  void selectStatusFilter(TaskStatusFilter filter) {
    _statusFilter.value = filter;
  }

  void selectSortOption(TaskSortOption option) {
    _sortOption.value = option;
  }

  Future<void> retryLoading() {
    return _bindTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      await _repository.markTaskCompleted(
        task.id,
        completed: task.status != TaskStatus.completed,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to toggle task completion.',
        tag: 'TasksController',
        context: <String, Object?>{'taskId': task.id},
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось обновить задачу',
        message: 'Статус не изменился. Попробуй ещё раз.',
      );
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await _repository.deleteTask(task.id);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to delete task.',
        tag: 'TasksController',
        context: <String, Object?>{'taskId': task.id},
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось удалить задачу',
        message: 'Задача осталась в списке. Попробуй ещё раз.',
      );
    }
  }

  Future<void> rescheduleTask(Task task, DateTime nextDate) async {
    try {
      await _repository.rescheduleTask(task.id, date: nextDate);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to reschedule task.',
        tag: 'TasksController',
        context: <String, Object?>{
          'taskId': task.id,
          'nextDate': nextDate.toIso8601String(),
        },
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось перенести задачу',
        message: 'Дата не изменилась. Попробуй ещё раз.',
      );
    }
  }

  Future<void> _bindTasks() async {
    if (_subscription != null) {
      await _subscription!.cancel();
    }
    _loading.value = true;
    _errorMessage.value = null;

    try {
      _tasks.assignAll(await _loadCurrentTasks());
      _loading.value = false;
      _subscription = _currentTaskStream().listen(
        (List<Task> tasks) {
          _tasks.assignAll(tasks);
          _loading.value = false;
          _errorMessage.value = null;
        },
        onError: (Object error, StackTrace stackTrace) {
          _handleLoadError(
            error,
            stackTrace,
            message: 'Не удалось обновить список задач.',
          );
        },
      );
    } catch (error, stackTrace) {
      _handleLoadError(
        error,
        stackTrace,
        message: 'Не удалось загрузить задачи.',
      );
    }
  }

  Future<List<Task>> _loadCurrentTasks() {
    return switch (listMode) {
      TaskListMode.forDay => _repository.getTasksByDate(selectedDate),
      TaskListMode.allTasks => _repository.getAllTasks(),
    };
  }

  Stream<List<Task>> _currentTaskStream() {
    return switch (listMode) {
      TaskListMode.forDay => _repository.watchTasksByDate(selectedDate),
      TaskListMode.allTasks => _repository.watchAllTasks(),
    };
  }

  void _handleLoadError(
    Object error,
    StackTrace stackTrace, {
    required String message,
  }) {
    _tasks.clear();
    _loading.value = false;
    _errorMessage.value = message;
    _logger.error(
      message,
      tag: 'TasksController',
      context: <String, Object?>{
        'mode': listMode.name,
        'selectedDate': selectedDate.toIso8601String(),
      },
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _taskComparator(Task a, Task b) {
    final int byStatus = a.status.index.compareTo(b.status.index);
    if (byStatus != 0) {
      return byStatus;
    }

    return switch (sortOption) {
      TaskSortOption.chronological => _compareChronologically(a, b),
      TaskSortOption.priorityFirst => _compareByPriority(a, b),
    };
  }

  int _compareChronologically(Task a, Task b) {
    final int byDate = a.date.compareTo(b.date);
    if (listMode == TaskListMode.allTasks && byDate != 0) {
      return byDate;
    }

    final int byAllDay = _compareAllDay(a, b);
    if (byAllDay != 0) {
      return byAllDay;
    }

    final int byStartTime = _compareStartTime(a, b);
    if (byStartTime != 0) {
      return byStartTime;
    }

    final int byPriority = b.priority.sortWeight.compareTo(
      a.priority.sortWeight,
    );
    if (byPriority != 0) {
      return byPriority;
    }

    return a.createdAt.compareTo(b.createdAt);
  }

  int _compareByPriority(Task a, Task b) {
    final int byPriority = b.priority.sortWeight.compareTo(
      a.priority.sortWeight,
    );
    if (byPriority != 0) {
      return byPriority;
    }

    final int byDate = a.date.compareTo(b.date);
    if (byDate != 0) {
      return byDate;
    }

    final int byAllDay = _compareAllDay(a, b);
    if (byAllDay != 0) {
      return byAllDay;
    }

    final int byStartTime = _compareStartTime(a, b);
    if (byStartTime != 0) {
      return byStartTime;
    }

    return a.createdAt.compareTo(b.createdAt);
  }

  int _compareAllDay(Task a, Task b) {
    if (a.isAllDay == b.isAllDay) {
      return 0;
    }

    return a.isAllDay ? -1 : 1;
  }

  int _compareStartTime(Task a, Task b) {
    final DateTime farFuture = DateTime(9999);
    return (a.startTime ?? farFuture).compareTo(b.startTime ?? farFuture);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
