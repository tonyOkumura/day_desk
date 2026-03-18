import 'dart:async';
import 'package:get/get.dart';

import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/notifications/app_notification_service.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_checklist_item.dart';
import '../../domain/entities/task_quadrant.dart';
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
  final Rx<TaskViewMode> _viewMode = TaskViewMode.matrix.obs;
  final Rx<TaskScopeMode> _scopeMode = TaskScopeMode.forDay.obs;
  final Rx<DateTime> _selectedDate;
  final Rx<TaskCategoryFilter> _categoryFilter = TaskCategoryFilter.all.obs;
  final Rx<TaskListSortOption> _listSortOption =
      TaskListSortOption.deadlineFirst.obs;
  final RxString _searchQuery = ''.obs;
  final RxMap<TaskQuadrant, bool> _compactQuadrantExpanded =
      <TaskQuadrant, bool>{
        for (final TaskQuadrant quadrant in TaskQuadrant.values) quadrant: true,
      }.obs;

  StreamSubscription<List<Task>>? _subscription;

  List<TaskViewMode> get viewModes => TaskViewMode.values;
  List<TaskScopeMode> get scopeModes => TaskScopeMode.values;
  List<TaskCategoryFilter> get categoryFilters => TaskCategoryFilter.values;
  List<TaskListSortOption> get listSortOptions => TaskListSortOption.values;
  TaskViewMode get viewMode => _viewMode.value;
  TaskScopeMode get scopeMode => _scopeMode.value;
  DateTime get selectedDate => _selectedDate.value;
  TaskCategoryFilter get categoryFilter => _categoryFilter.value;
  TaskListSortOption get listSortOption => _listSortOption.value;
  String get searchQuery => _searchQuery.value;
  bool get isLoading => _loading.value;
  String? get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value != null;
  bool get hasSourceTasks => _tasks.isNotEmpty;
  String get selectedDateLabel => _dateFormatter.formatFullDate(selectedDate);
  bool get hasActiveFilters {
    final DateTime today = _dateFormatter.startOfDay(DateTime.now());
    return scopeMode != TaskScopeMode.forDay ||
        !_dateFormatter.isSameDay(selectedDate, today) ||
        categoryFilter != TaskCategoryFilter.all;
  }

  bool get hasActiveSortOverride {
    return listSortOption != TaskListSortOption.deadlineFirst;
  }

  bool isQuadrantExpanded(TaskQuadrant quadrant) {
    return _compactQuadrantExpanded[quadrant] ?? true;
  }

  List<Task> get visibleTasks {
    final List<Task> sorted = _filteredTasks.toList(growable: false);
    sorted.sort(_listComparator);
    return sorted;
  }

  List<TaskQuadrantGroup> get matrixGroups {
    final List<Task> filtered = _filteredTasks.toList(growable: false);
    return TaskQuadrant.values
        .toList(growable: false)
        .map((TaskQuadrant quadrant) {
          final List<Task> tasks =
              filtered
                  .where((Task task) => task.quadrant == quadrant)
                  .toList(growable: false)
                ..sort(_matrixComparator);
          return TaskQuadrantGroup(quadrant: quadrant, tasks: tasks);
        })
        .toList(growable: false)
      ..sort(
        (TaskQuadrantGroup left, TaskQuadrantGroup right) =>
            left.quadrant.sortOrder.compareTo(right.quadrant.sortOrder),
      );
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(_bindTasks());
  }

  void selectViewMode(TaskViewMode mode) {
    _viewMode.value = mode;
  }

  Future<void> selectScopeMode(TaskScopeMode mode) async {
    if (mode == scopeMode) {
      return;
    }

    _scopeMode.value = mode;
    await _bindTasks();
  }

  Future<void> selectDate(DateTime date) async {
    final DateTime normalizedDate = _dateFormatter.startOfDay(date);
    if (_dateFormatter.isSameDay(normalizedDate, selectedDate)) {
      return;
    }

    _selectedDate.value = normalizedDate;
    if (scopeMode == TaskScopeMode.forDay) {
      await _bindTasks();
    }
  }

  void selectCategoryFilter(TaskCategoryFilter filter) {
    _categoryFilter.value = filter;
  }

  void selectListSortOption(TaskListSortOption option) {
    _listSortOption.value = option;
  }

  void updateSearchQuery(String value) {
    _searchQuery.value = value;
  }

  void setQuadrantExpanded(TaskQuadrant quadrant, bool expanded) {
    _compactQuadrantExpanded[quadrant] = expanded;
  }

  Future<void> resetFilters() async {
    _categoryFilter.value = TaskCategoryFilter.all;
    _scopeMode.value = TaskScopeMode.forDay;
    _selectedDate.value = _dateFormatter.startOfDay(DateTime.now());
    await _bindTasks();
  }

  void resetSort() {
    _listSortOption.value = TaskListSortOption.deadlineFirst;
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

  Future<void> reclassifyTask(Task task, TaskQuadrant quadrant) async {
    try {
      await _repository.updateTaskQuadrant(task.id, quadrant: quadrant);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to reclassify task.',
        tag: 'TasksController',
        context: <String, Object?>{
          'taskId': task.id,
          'quadrant': quadrant.name,
        },
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось изменить квадрант',
        message: 'Попробуй ещё раз.',
      );
    }
  }

  Future<void> toggleSubtaskCompletion(
    Task task,
    TaskChecklistItem subtask,
  ) async {
    try {
      await _repository.toggleSubtaskCompleted(
        task.id,
        subtask.id,
        completed: !subtask.isCompleted,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to toggle subtask completion.',
        tag: 'TasksController',
        context: <String, Object?>{'taskId': task.id, 'subtaskId': subtask.id},
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось обновить подпункт',
        message: 'Состояние подпункта не изменилось. Попробуй ещё раз.',
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
    return switch (scopeMode) {
      TaskScopeMode.forDay => _repository.getTasksByDate(selectedDate),
      TaskScopeMode.allTasks => _repository.getAllTasks(),
    };
  }

  Stream<List<Task>> _currentTaskStream() {
    return switch (scopeMode) {
      TaskScopeMode.forDay => _repository.watchTasksByDate(selectedDate),
      TaskScopeMode.allTasks => _repository.watchAllTasks(),
    };
  }

  Iterable<Task> get _filteredTasks {
    return _tasks.where((Task task) {
      return _categoryFilter.value.matches(task.category) &&
          _matchesSearch(task);
    });
  }

  bool _matchesSearch(Task task) {
    final String query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }

    if (task.title.toLowerCase().contains(query)) {
      return true;
    }

    return task.subtasks.any(
      (TaskChecklistItem item) => item.title.toLowerCase().contains(query),
    );
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
        'scopeMode': scopeMode.name,
        'selectedDate': selectedDate.toIso8601String(),
      },
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _listComparator(Task a, Task b) {
    final int byStatus = _statusPriority(a).compareTo(_statusPriority(b));
    if (byStatus != 0) {
      return byStatus;
    }

    return switch (listSortOption) {
      TaskListSortOption.deadlineFirst => _compareByActionMoment(a, b),
      TaskListSortOption.dateTime => _compareByDateTime(a, b),
      TaskListSortOption.recentlyUpdated => b.updatedAt.compareTo(a.updatedAt),
    };
  }

  int _matrixComparator(Task a, Task b) {
    final int byStatus = _statusPriority(a).compareTo(_statusPriority(b));
    if (byStatus != 0) {
      return byStatus;
    }

    final int byMoment = _compareByActionMoment(a, b);
    if (byMoment != 0) {
      return byMoment;
    }

    return b.updatedAt.compareTo(a.updatedAt);
  }

  int _compareByActionMoment(Task a, Task b) {
    final DateTime leftMoment = _taskActionMoment(a);
    final DateTime rightMoment = _taskActionMoment(b);
    final int byMoment = leftMoment.compareTo(rightMoment);
    if (byMoment != 0) {
      return byMoment;
    }

    return _compareByDateTime(a, b);
  }

  int _compareByDateTime(Task a, Task b) {
    final int byDate = a.date.compareTo(b.date);
    if (scopeMode == TaskScopeMode.allTasks && byDate != 0) {
      return byDate;
    }

    if (a.isAllDay != b.isAllDay) {
      return a.isAllDay ? -1 : 1;
    }

    final DateTime farFuture = DateTime(9999);
    final int byStart = (a.startTime ?? farFuture).compareTo(
      b.startTime ?? farFuture,
    );
    if (byStart != 0) {
      return byStart;
    }

    return a.createdAt.compareTo(b.createdAt);
  }

  DateTime _taskActionMoment(Task task) {
    return task.deadline ??
        task.startTime ??
        DateTime(task.date.year, task.date.month, task.date.day + 1);
  }

  int _statusPriority(Task task) {
    if (task.isOverdue) {
      return 0;
    }
    if (!task.isCompleted) {
      return 1;
    }
    return 2;
  }
}

class TaskQuadrantGroup {
  const TaskQuadrantGroup({required this.quadrant, required this.tasks});

  final TaskQuadrant quadrant;
  final List<Task> tasks;
}
