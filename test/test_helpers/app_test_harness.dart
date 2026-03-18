import 'dart:async';

import 'package:day_desk/app/bindings/app_binding.dart';
import 'package:day_desk/app/bootstrap/app_startup_state.dart';
import 'package:day_desk/app/day_desk_app.dart';
import 'package:day_desk/core/date/app_date_formatter.dart';
import 'package:day_desk/core/logging/app_logger.dart';
import 'package:day_desk/core/notifications/app_notification_service.dart';
import 'package:day_desk/core/notifications/notification_config.dart';
import 'package:day_desk/core/reminders/reminder_lead_time_preset.dart';
import 'package:day_desk/features/settings/domain/entities/app_settings.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_palette.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_preference.dart';
import 'package:day_desk/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:day_desk/features/tasks/domain/entities/task.dart';
import 'package:day_desk/features/tasks/domain/entities/task_checklist_item.dart';
import 'package:day_desk/features/tasks/domain/entities/task_quadrant.dart';
import 'package:day_desk/features/tasks/domain/entities/task_status.dart';
import 'package:day_desk/features/tasks/domain/repositories/task_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppTestHarness {
  AppTestHarness._(this.repository, this.taskRepository);

  final FakeAppSettingsRepository repository;
  final FakeTaskRepository taskRepository;

  static Future<AppTestHarness> bootstrap({
    FakeAppSettingsRepository? repository,
    FakeTaskRepository? taskRepository,
  }) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
    await initializeDateFormatting(AppDateFormatter.localeName);

    final FakeAppSettingsRepository resolvedRepository =
        repository ?? FakeAppSettingsRepository();
    final FakeTaskRepository resolvedTaskRepository =
        taskRepository ?? FakeTaskRepository();

    if (!Get.isRegistered<AppLogger>()) {
      Get.put<AppLogger>(AppLogger(), permanent: true);
    }

    if (!Get.isRegistered<AppNotificationService>()) {
      Get.put<AppNotificationService>(
        FakeAppNotificationService(),
        permanent: true,
      );
    }

    Get.put<AppSettingsRepository>(resolvedRepository, permanent: true);
    Get.put<TaskRepository>(resolvedTaskRepository, permanent: true);
    Get.put<AppStartupState>(
      AppStartupState(initialSettings: await resolvedRepository.readSettings()),
      permanent: true,
    );

    AppBinding().dependencies();

    return AppTestHarness._(resolvedRepository, resolvedTaskRepository);
  }

  static void setSurfaceSize(WidgetTester tester, {required Size size}) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
  }

  static void resetSurfaceSize(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await pumpAppWithRoute(tester);
  }

  Future<void> pumpAppWithRoute(
    WidgetTester tester, {
    String? initialRoute,
  }) async {
    await tester.pumpWidget(DayDeskApp(initialRoute: initialRoute));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> dispose() async {
    await taskRepository.dispose();
    Get.reset();
  }
}

class FakeAppNotificationService extends AppNotificationService {
  FakeAppNotificationService() : super(logger: AppLogger());

  final List<({String title, String message})> infoEvents =
      <({String title, String message})>[];
  final List<({String title, String message})> successEvents =
      <({String title, String message})>[];
  final List<({String title, String message})> errorEvents =
      <({String title, String message})>[];

  @override
  void show(NotificationConfig config) {
    switch (config.type) {
      case NotificationType.info:
        infoEvents.add((title: config.title, message: config.message ?? ''));
      case NotificationType.success:
        successEvents.add((title: config.title, message: config.message ?? ''));
      case NotificationType.error:
        errorEvents.add((title: config.title, message: config.message ?? ''));
    }
  }

  @override
  void showInfo({
    required String title,
    String? message,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    infoEvents.add((title: title, message: message ?? ''));
  }

  @override
  void showSuccess({
    required String title,
    String? message,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    successEvents.add((title: title, message: message ?? ''));
  }

  @override
  void showError({
    required String title,
    String? message,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    errorEvents.add((title: title, message: message ?? ''));
  }
}

class FakeAppSettingsRepository implements AppSettingsRepository {
  FakeAppSettingsRepository({AppSettings? initialSettings})
    : _settings =
          initialSettings ??
          const AppSettings(
            themePreference: AppThemePreference.dark,
            themePalette: AppThemePalette.blue,
          );

  AppSettings _settings;

  @override
  Future<AppSettings> readSettings() async {
    return _settings;
  }

  @override
  Future<void> saveThemePreference(AppThemePreference preference) async {
    _settings = _settings.copyWith(themePreference: preference);
  }

  @override
  Future<void> saveThemePalette(AppThemePalette palette) async {
    _settings = _settings.copyWith(themePalette: palette);
  }

  @override
  Future<void> saveWorkDayBounds({
    required int startHour,
    required int endHour,
  }) async {
    _settings = _settings.copyWith(
      workDayStartHour: startHour,
      workDayEndHour: endHour,
    );
  }

  @override
  Future<void> saveMinimumFreeSlotMinutes(int minutes) async {
    _settings = _settings.copyWith(minimumFreeSlotMinutes: minutes);
  }

  @override
  Future<void> saveDefaultReminderPreset(ReminderLeadTimePreset preset) async {
    _settings = _settings.copyWith(defaultReminderPreset: preset);
  }

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
  }

  @override
  Future<void> resetSettings() async {
    _settings = const AppSettings();
  }
}

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({
    List<Task>? initialTasks,
    DateTime Function()? nowProvider,
    this.failOnLoad = false,
    this.failOnDelete = false,
    this.failOnUpdate = false,
    this.failOnCreate = false,
  }) : _tasks = List<Task>.from(initialTasks ?? const <Task>[]),
       _nowProvider = nowProvider ?? DateTime.now;

  final List<Task> _tasks;
  final DateTime Function() _nowProvider;
  final bool failOnLoad;
  final bool failOnDelete;
  final bool failOnUpdate;
  final bool failOnCreate;
  final StreamController<List<Task>> _streamController =
      StreamController<List<Task>>.broadcast();

  @override
  Future<void> createTask(Task task) async {
    if (failOnCreate) {
      throw StateError('create failed');
    }

    _tasks.add(task.normalizedForPersistence());
    _emit();
  }

  @override
  Future<void> updateTask(Task task) async {
    if (failOnUpdate) {
      throw StateError('update failed');
    }

    final int index = _tasks.indexWhere((Task item) => item.id == task.id);
    if (index < 0) {
      throw StateError('task not found');
    }

    _tasks[index] = task.normalizedForPersistence();
    _emit();
  }

  @override
  Future<void> deleteTask(String taskId) async {
    if (failOnDelete) {
      throw StateError('delete failed');
    }

    _tasks.removeWhere((Task task) => task.id == taskId);
    _emit();
  }

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async {
    if (failOnLoad) {
      throw StateError('load failed');
    }

    final DateTime dayStart = DateTime(date.year, date.month, date.day);
    final DateTime nextDay = dayStart.add(const Duration(days: 1));
    return _tasks
        .where((Task task) {
          return !task.date.isBefore(dayStart) && task.date.isBefore(nextDay);
        })
        .map(_materializeTask)
        .toList(growable: false);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    if (failOnLoad) {
      throw StateError('load failed');
    }

    return List<Task>.unmodifiable(_tasks.map(_materializeTask));
  }

  @override
  Stream<List<Task>> watchTasksByDate(DateTime date) async* {
    yield await getTasksByDate(date);
    yield* _streamController.stream.map((List<Task> tasks) {
      final DateTime dayStart = DateTime(date.year, date.month, date.day);
      final DateTime nextDay = dayStart.add(const Duration(days: 1));
      return tasks
          .where((Task task) {
            return !task.date.isBefore(dayStart) && task.date.isBefore(nextDay);
          })
          .map(_materializeTask)
          .toList(growable: false);
    });
  }

  @override
  Stream<List<Task>> watchAllTasks() async* {
    yield await getAllTasks();
    yield* _streamController.stream;
  }

  @override
  Future<void> markTaskCompleted(
    String taskId, {
    required bool completed,
  }) async {
    final Task task = _tasks.firstWhere((Task item) => item.id == taskId);
    await updateTask(
      task.copyWith(
        status: completed ? TaskStatus.completed : TaskStatus.pending,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateTaskQuadrant(
    String taskId, {
    required TaskQuadrant quadrant,
  }) async {
    final Task task = _tasks.firstWhere((Task item) => item.id == taskId);
    await updateTask(
      task.copyWith(
        isUrgent: quadrant.isUrgent,
        isImportant: quadrant.isImportant,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> toggleSubtaskCompleted(
    String taskId,
    String subtaskId, {
    required bool completed,
  }) async {
    final Task task = _tasks.firstWhere((Task item) => item.id == taskId);
    await updateTask(
      task.copyWith(
        subtasks: task.subtasks
            .map((TaskChecklistItem item) {
              if (item.id != subtaskId) {
                return item;
              }

              return item.copyWith(isCompleted: completed);
            })
            .toList(growable: false),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> rescheduleTask(
    String taskId, {
    required DateTime date,
    DateTime? startTime,
  }) async {
    final Task task = _tasks.firstWhere((Task item) => item.id == taskId);
    final DateTime? nextStartTime = startTime ?? task.startTime;
    await updateTask(
      task.copyWith(
        date: DateTime(date.year, date.month, date.day),
        startTime: nextStartTime == null
            ? null
            : DateTime(
                date.year,
                date.month,
                date.day,
                nextStartTime.hour,
                nextStartTime.minute,
                nextStartTime.second,
                nextStartTime.millisecond,
                nextStartTime.microsecond,
              ),
        deadline: task.deadline == null
            ? null
            : DateTime(
                date.year,
                date.month,
                date.day,
                task.deadline!.hour,
                task.deadline!.minute,
                task.deadline!.second,
                task.deadline!.millisecond,
                task.deadline!.microsecond,
              ),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> dispose() async {
    await _streamController.close();
  }

  void _emit() {
    _streamController.add(List<Task>.unmodifiable(_tasks));
  }

  Task _materializeTask(Task task) {
    return task.withResolvedReminderSchedule().copyWith(
      evaluationTime: _nowProvider(),
    );
  }
}
