import 'dart:math';

import 'package:get/get.dart';

import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/notifications/app_notification_service.dart';
import '../../../../core/reminders/reminder_lead_time_preset.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';

class TaskEditorController {
  TaskEditorController({
    required TaskRepository repository,
    required AppDateFormatter dateFormatter,
    required AppLogger logger,
    required AppNotificationService notificationService,
    ReminderLeadTimePreset defaultReminderPreset =
        ReminderLeadTimePreset.minutes15,
    Task? initialTask,
    DateTime? initialDate,
  }) : _repository = repository,
       _dateFormatter = dateFormatter,
       _logger = logger,
       _notificationService = notificationService,
       _persistedTask = initialTask,
       _title = (initialTask?.title ?? '').obs,
       _description = (initialTask?.description ?? '').obs,
       _date = dateFormatter
           .startOfDay(initialTask?.date ?? initialDate ?? DateTime.now())
           .obs,
       _startTime = Rxn<DateTime>(initialTask?.startTime),
       _durationMinutes = RxnInt(initialTask?.durationMinutes),
       _deadline = Rxn<DateTime>(initialTask?.deadline),
       _reminderPreset =
           (initialTask?.reminderPreset ?? defaultReminderPreset).obs,
       _priority = (initialTask?.priority ?? TaskPriority.medium).obs,
       _category = (initialTask?.category ?? TaskCategory.other).obs,
       _isAllDay = (initialTask?.isAllDay ?? false).obs,
       _status = (_normalizeEditorStatus(initialTask?.status)).obs,
       _saving = false.obs {
    _initialSnapshot = _snapshot;
  }

  static const List<int> durationOptions = <int>[15, 30, 45, 60, 90, 120];

  final TaskRepository _repository;
  final AppDateFormatter _dateFormatter;
  final AppLogger _logger;
  final AppNotificationService _notificationService;

  final RxString _title;
  final RxString _description;
  final Rx<DateTime> _date;
  final Rxn<DateTime> _startTime;
  final RxnInt _durationMinutes;
  final Rxn<DateTime> _deadline;
  final Rx<ReminderLeadTimePreset> _reminderPreset;
  final Rx<TaskPriority> _priority;
  final Rx<TaskCategory> _category;
  final RxBool _isAllDay;
  final Rx<TaskStatus> _status;
  final RxBool _saving;
  final RxnString _titleError = RxnString();

  Task? _persistedTask;
  late _TaskEditorSnapshot _initialSnapshot;

  bool get isEditing => _persistedTask != null;
  bool get isSaving => _saving.value;
  bool get isAllDay => _isAllDay.value;
  bool get canEditDuration => !isAllDay && _startTime.value != null;
  bool get hasUnsavedChanges => _snapshot != _initialSnapshot;
  String get title => _title.value;
  String get description => _description.value;
  DateTime get date => _date.value;
  DateTime? get startTime => _startTime.value;
  int? get durationMinutes => _durationMinutes.value;
  DateTime? get deadline => _deadline.value;
  ReminderLeadTimePreset get reminderPreset => _reminderPreset.value;
  DateTime? get resolvedReminderAt => _draftReminderAt();
  TaskPriority get priority => _priority.value;
  TaskCategory get category => _category.value;
  TaskStatus get status => _status.value;
  String? get titleError => _titleError.value;
  String get titleText => isEditing ? 'Редактировать задачу' : 'Новая задача';
  String get saveLabel => isEditing ? 'Сохранить' : 'Создать';
  String get dateLabel => _dateFormatter.formatFullDate(_date.value);
  String get deadlineLabel => _deadline.value == null
      ? 'Без дедлайна'
      : _dateFormatter.formatDateTime(_deadline.value!);
  String get startTimeLabel => _startTime.value == null
      ? 'Без времени'
      : _dateFormatter.formatTime(_startTime.value!);
  List<TaskStatus> get editableStatuses => TaskStatus.editorValues;
  List<ReminderLeadTimePreset> get reminderPresetOptions =>
      ReminderLeadTimePreset.values;
  String? get reminderHelperText {
    if (!reminderPreset.hasReminder) {
      return null;
    }

    final DateTime? reminderAt = resolvedReminderAt;
    if (reminderAt != null) {
      return 'Сработает ${_dateFormatter.formatDateTime(reminderAt)}';
    }

    return 'Напоминание активируется, когда появится дедлайн или точное время.';
  }

  void updateTitle(String value) {
    _title.value = value;
    if (value.trim().isNotEmpty) {
      _titleError.value = null;
    }
  }

  void updateDescription(String value) {
    _description.value = value;
  }

  void updateDate(DateTime value) {
    final DateTime normalizedDate = _dateFormatter.startOfDay(value);
    _date.value = normalizedDate;

    final DateTime? currentStartTime = _startTime.value;
    if (currentStartTime != null) {
      _startTime.value = DateTime(
        normalizedDate.year,
        normalizedDate.month,
        normalizedDate.day,
        currentStartTime.hour,
        currentStartTime.minute,
      );
    }
  }

  void updateDeadline(DateTime? value) {
    _deadline.value = value;
  }

  void updateReminderPreset(ReminderLeadTimePreset value) {
    _reminderPreset.value = value;
  }

  void setAllDay(bool value) {
    _isAllDay.value = value;
    if (value) {
      _startTime.value = null;
      _durationMinutes.value = null;
    }
  }

  void updateStartTime(DateTime? value) {
    if (value == null) {
      _startTime.value = null;
      _durationMinutes.value = null;
      return;
    }

    final DateTime selectedDate = _date.value;
    _startTime.value = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      value.hour,
      value.minute,
    );
  }

  void updateDurationMinutes(int? value) {
    if (!canEditDuration) {
      _durationMinutes.value = null;
      return;
    }

    _durationMinutes.value = value;
  }

  void updatePriority(TaskPriority value) {
    _priority.value = value;
  }

  void updateCategory(TaskCategory value) {
    _category.value = value;
  }

  void updateStatus(TaskStatus value) {
    if (!value.selectableInEditor) {
      return;
    }

    _status.value = value;
  }

  Future<Task?> save() async {
    final bool wasEditing = isEditing;
    final String trimmedTitle = _title.value.trim();
    if (trimmedTitle.isEmpty) {
      _titleError.value = 'Укажи название задачи';
      return null;
    }

    final DateTime now = DateTime.now();
    final Task task = _buildDraftTask(
      title: trimmedTitle,
      description: _description.value.trim(),
      updatedAt: now,
      createdAt: _persistedTask?.createdAt ?? now,
    );

    _saving.value = true;
    try {
      if (wasEditing) {
        await _repository.updateTask(task);
      } else {
        await _repository.createTask(task);
      }

      _persistedTask = task;
      _initialSnapshot = _snapshot;
      _logger.info(
        'Task saved.',
        tag: 'TaskEditorController',
        context: <String, Object?>{'taskId': task.id, 'isEditing': wasEditing},
      );
      return task;
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save task.',
        tag: 'TaskEditorController',
        context: <String, Object?>{'taskId': task.id, 'isEditing': wasEditing},
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось сохранить задачу',
        message: 'Изменения не применились. Попробуй ещё раз.',
      );
      return null;
    } finally {
      _saving.value = false;
    }
  }

  String _generateTaskId() {
    return '${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}-'
        '${Random().nextInt(1 << 32).toRadixString(16)}';
  }

  _TaskEditorSnapshot get _snapshot {
    return _TaskEditorSnapshot(
      title: _title.value.trim(),
      description: _description.value.trim(),
      date: _dateFormatter.startOfDay(_date.value),
      startTime: _startTime.value,
      durationMinutes: _durationMinutes.value,
      deadline: _deadline.value,
      reminderPreset: _reminderPreset.value,
      priority: _priority.value,
      category: _category.value,
      isAllDay: _isAllDay.value,
      status: _status.value,
    );
  }

  Task _buildDraftTask({
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final String resolvedTitle = title ?? _title.value.trim();
    final String resolvedDescription = description ?? _description.value.trim();

    return Task(
      id: _persistedTask?.id ?? _generateTaskId(),
      title: resolvedTitle,
      description: resolvedDescription.isEmpty ? null : resolvedDescription,
      date: _dateFormatter.startOfDay(_date.value),
      startTime: _isAllDay.value ? null : _startTime.value,
      durationMinutes: _isAllDay.value ? null : _durationMinutes.value,
      deadline: _deadline.value,
      reminderPreset: _reminderPreset.value,
      reminderAt: _draftReminderAt(),
      priority: _priority.value,
      status: _status.value,
      category: _category.value,
      isAllDay: _isAllDay.value,
      createdAt: createdAt ?? _persistedTask?.createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  DateTime? _draftReminderAt() {
    return _reminderPreset.value.resolveReminderAt(_draftReminderAnchor());
  }

  DateTime? _draftReminderAnchor() {
    if (_deadline.value != null) {
      return _deadline.value;
    }
    if (!_isAllDay.value && _startTime.value != null) {
      return _startTime.value;
    }
    if (_isAllDay.value) {
      final DateTime selectedDate = _date.value;
      return DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    }

    return null;
  }

  static TaskStatus _normalizeEditorStatus(TaskStatus? status) {
    if (status == null || status == TaskStatus.overdue) {
      return TaskStatus.pending;
    }

    return status;
  }
}

class _TaskEditorSnapshot {
  const _TaskEditorSnapshot({
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.durationMinutes,
    required this.deadline,
    required this.reminderPreset,
    required this.priority,
    required this.category,
    required this.isAllDay,
    required this.status,
  });

  final String title;
  final String description;
  final DateTime date;
  final DateTime? startTime;
  final int? durationMinutes;
  final DateTime? deadline;
  final ReminderLeadTimePreset reminderPreset;
  final TaskPriority priority;
  final TaskCategory category;
  final bool isAllDay;
  final TaskStatus status;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _TaskEditorSnapshot &&
        other.title == title &&
        other.description == description &&
        other.date == date &&
        other.startTime == startTime &&
        other.durationMinutes == durationMinutes &&
        other.deadline == deadline &&
        other.reminderPreset == reminderPreset &&
        other.priority == priority &&
        other.category == category &&
        other.isAllDay == isAllDay &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      description,
      date,
      startTime,
      durationMinutes,
      deadline,
      reminderPreset,
      priority,
      category,
      isAllDay,
      status,
    );
  }
}
