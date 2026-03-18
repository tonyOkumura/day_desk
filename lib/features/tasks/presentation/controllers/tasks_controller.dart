import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';

import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/notifications/app_notification_service.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/repositories/app_settings_repository.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_checklist_item.dart';
import '../../domain/entities/task_quadrant.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_list_options.dart';

class TasksController extends GetxController {
  TasksController({
    required TaskRepository repository,
    required AppSettingsRepository settingsRepository,
    required AppDateFormatter dateFormatter,
    required AppLogger logger,
    required AppNotificationService notificationService,
  }) : _repository = repository,
       _settingsRepository = settingsRepository,
       _dateFormatter = dateFormatter,
       _logger = logger,
       _notificationService = notificationService,
       _selectedDate = dateFormatter.startOfDay(DateTime.now()).obs;

  final TaskRepository _repository;
  final AppSettingsRepository _settingsRepository;
  final AppDateFormatter _dateFormatter;
  final AppLogger _logger;
  final AppNotificationService _notificationService;

  final RxList<Task> _tasks = <Task>[].obs;
  final RxBool _loading = true.obs;
  final RxnString _errorMessage = RxnString();
  final Rx<TaskViewMode> _viewMode = TaskViewMode.matrix.obs;
  final Rx<TaskScopeMode> _scopeMode = TaskScopeMode.forDay.obs;
  final Rx<DateTime> _selectedDate;
  final Rx<TaskStatusFilter> _statusFilter = TaskStatusFilter.active.obs;
  final Rx<TaskCategoryFilter> _categoryFilter = TaskCategoryFilter.all.obs;
  final Rx<TaskListSortOption> _listSortOption =
      TaskListSortOption.deadlineFirst.obs;
  final RxString _quickCaptureTitle = ''.obs;
  final Rx<TaskQuadrant> _quickCaptureQuadrant = TaskQuadrant.schedule.obs;

  StreamSubscription<List<Task>>? _subscription;

  List<TaskViewMode> get viewModes => TaskViewMode.values;
  List<TaskScopeMode> get scopeModes => TaskScopeMode.values;
  List<TaskStatusFilter> get statusFilters => TaskStatusFilter.values;
  List<TaskCategoryFilter> get categoryFilters => TaskCategoryFilter.values;
  List<TaskListSortOption> get listSortOptions => TaskListSortOption.values;
  TaskViewMode get viewMode => _viewMode.value;
  TaskScopeMode get scopeMode => _scopeMode.value;
  DateTime get selectedDate => _selectedDate.value;
  TaskStatusFilter get statusFilter => _statusFilter.value;
  TaskCategoryFilter get categoryFilter => _categoryFilter.value;
  TaskListSortOption get listSortOption => _listSortOption.value;
  bool get isLoading => _loading.value;
  String? get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value != null;
  bool get hasSourceTasks => _tasks.isNotEmpty;
  String get selectedDateLabel => _dateFormatter.formatFullDate(selectedDate);
  String get quickCaptureTitle => _quickCaptureTitle.value;
  TaskQuadrant get quickCaptureQuadrant => _quickCaptureQuadrant.value;
  bool get canSubmitQuickCapture => quickCaptureTitle.trim().isNotEmpty;

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

  void selectStatusFilter(TaskStatusFilter filter) {
    _statusFilter.value = filter;
  }

  void selectCategoryFilter(TaskCategoryFilter filter) {
    _categoryFilter.value = filter;
  }

  void selectListSortOption(TaskListSortOption option) {
    _listSortOption.value = option;
  }

  void updateQuickCaptureTitle(String value) {
    _quickCaptureTitle.value = value;
  }

  void updateQuickCaptureQuadrant(TaskQuadrant value) {
    _quickCaptureQuadrant.value = value;
  }

  Future<void> submitQuickCapture() async {
    final String title = quickCaptureTitle.trim();
    if (title.isEmpty) {
      return;
    }

    try {
      final AppSettings settings = await _settingsRepository.readSettings();
      final DateTime date = scopeMode == TaskScopeMode.forDay
          ? selectedDate
          : _dateFormatter.startOfDay(DateTime.now());
      final DateTime now = DateTime.now();

      await _repository.createTask(
        Task(
          id: _generateId(),
          title: title,
          date: date,
          reminderPreset: settings.defaultReminderPreset,
          isUrgent: quickCaptureQuadrant.isUrgent,
          isImportant: quickCaptureQuadrant.isImportant,
          status: TaskStatus.pending,
          createdAt: now,
          updatedAt: now,
        ),
      );

      _quickCaptureTitle.value = '';
      _quickCaptureQuadrant.value = TaskQuadrant.schedule;
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to create quick task.',
        tag: 'TasksController',
        context: <String, Object?>{
          'scopeMode': scopeMode.name,
          'quadrant': quickCaptureQuadrant.name,
        },
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось создать задачу',
        message: 'Быстрый захват не сохранился. Попробуй ещё раз.',
      );
    }
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

  Future<void> toggleTaskPostponed(Task task) async {
    if (task.status == TaskStatus.completed) {
      return;
    }

    try {
      await _repository.setTaskPostponed(
        task.id,
        postponed: task.status != TaskStatus.postponed,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to toggle task postponed state.',
        tag: 'TasksController',
        context: <String, Object?>{'taskId': task.id},
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось изменить статус задачи',
        message: 'Попробуй ещё раз.',
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
      return _matchesStatusFilter(task) &&
          _categoryFilter.value.matches(task.category);
    });
  }

  bool _matchesStatusFilter(Task task) {
    return switch (statusFilter) {
      TaskStatusFilter.active => task.status != TaskStatus.completed,
      TaskStatusFilter.all => true,
      TaskStatusFilter.pending => task.status == TaskStatus.pending,
      TaskStatusFilter.postponed => task.status == TaskStatus.postponed,
      TaskStatusFilter.overdue => task.status == TaskStatus.overdue,
      TaskStatusFilter.completed => task.status == TaskStatus.completed,
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
        'scopeMode': scopeMode.name,
        'selectedDate': selectedDate.toIso8601String(),
      },
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _listComparator(Task a, Task b) {
    final int byStatus = a.status.sortOrder.compareTo(b.status.sortOrder);
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
    final int byStatus = a.status.sortOrder.compareTo(b.status.sortOrder);
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

  String _generateId() {
    return '${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}-'
        '${Random().nextInt(1 << 32).toRadixString(16)}';
  }
}

class TaskQuadrantGroup {
  const TaskQuadrantGroup({required this.quadrant, required this.tasks});

  final TaskQuadrant quadrant;
  final List<Task> tasks;
}
