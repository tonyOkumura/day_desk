import 'package:day_desk/app/controllers/theme_controller.dart';
import 'package:day_desk/core/logging/app_logger.dart';
import 'package:day_desk/core/notifications/app_notification_service.dart';
import 'package:day_desk/core/notifications/notification_config.dart';
import 'package:day_desk/core/reminders/reminder_lead_time_preset.dart';
import 'package:day_desk/features/settings/domain/entities/app_settings.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_palette.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_preference.dart';
import 'package:day_desk/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:day_desk/features/settings/presentation/controllers/settings_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test(
    'успешное изменение foundation-настроек сохраняет состояние без success toast',
    () async {
      final RecordingAppLogger logger = RecordingAppLogger();
      final RecordingAppNotificationService notifications =
          RecordingAppNotificationService();
      final FakeSettingsRepository repository = FakeSettingsRepository();

      Get.put<RecordingAppLogger>(logger, permanent: true);
      Get.put<RecordingAppNotificationService>(notifications, permanent: true);

      final SettingsController controller = SettingsController(
        themeController: _buildThemeController(),
        logger: logger,
        notificationService: notifications,
        repository: repository,
        initialSettings: const AppSettings(),
      );

      await controller.setWorkDayStartHour(8);
      await controller.setWorkDayEndHour(19);
      await controller.setMinimumFreeSlotMinutes(45);
      await controller.setDefaultReminderPreset(ReminderLeadTimePreset.hour1);
      await controller.setNotificationsEnabled(false);

      expect(controller.workDayStartHour, 8);
      expect(controller.workDayEndHour, 19);
      expect(controller.minimumFreeSlotMinutes, 45);
      expect(controller.defaultReminderPreset, ReminderLeadTimePreset.hour1);
      expect(controller.notificationsEnabled, isFalse);
      expect(notifications.successEvents, isEmpty);
      expect(notifications.errorEvents, isEmpty);
    },
  );

  test('доступные часы не допускают невалидных границ дня', () {
    final SettingsController controller = SettingsController(
      themeController: _buildThemeController(),
      logger: RecordingAppLogger(),
      notificationService: RecordingAppNotificationService(),
      repository: FakeSettingsRepository(
        initialSettings: const AppSettings(
          workDayStartHour: 9,
          workDayEndHour: 18,
        ),
      ),
      initialSettings: const AppSettings(
        workDayStartHour: 9,
        workDayEndHour: 18,
      ),
    );

    expect(controller.availableStartHourOptions.contains(18), isFalse);
    expect(controller.availableEndHourOptions.contains(9), isFalse);
  });

  test(
    'ошибка сохранения foundation-настроек откатывает состояние и показывает error notification',
    () async {
      final RecordingAppLogger logger = RecordingAppLogger();
      final RecordingAppNotificationService notifications =
          RecordingAppNotificationService();
      final FakeSettingsRepository repository = FakeSettingsRepository(
        failOnSaveBounds: true,
      );

      final SettingsController controller = SettingsController(
        themeController: _buildThemeController(),
        logger: logger,
        notificationService: notifications,
        repository: repository,
        initialSettings: const AppSettings(),
      );

      await controller.setWorkDayStartHour(8);

      expect(controller.workDayStartHour, AppSettings.defaultWorkDayStartHour);
      expect(notifications.successEvents, isEmpty);
      expect(notifications.errorEvents, hasLength(1));
      expect(logger.errorEvents, hasLength(1));
    },
  );

  test(
    'успешный reset settings возвращает foundation-настройки к дефолтам',
    () async {
      final RecordingAppLogger logger = RecordingAppLogger();
      final RecordingAppNotificationService notifications =
          RecordingAppNotificationService();
      final FakeSettingsRepository repository = FakeSettingsRepository(
        initialSettings: const AppSettings(
          workDayStartHour: 8,
          workDayEndHour: 19,
          minimumFreeSlotMinutes: 45,
          defaultReminderPreset: ReminderLeadTimePreset.day1,
          notificationsEnabled: false,
        ),
      );
      final ThemeController themeController = ThemeController(
        logger: AppLogger(),
        notificationService: RecordingAppNotificationService(),
        repository: FakeSettingsRepository(),
        initialPreference: AppThemePreference.light,
        initialPalette: AppThemePalette.green,
      );
      final SettingsController controller = SettingsController(
        themeController: themeController,
        logger: logger,
        notificationService: notifications,
        repository: repository,
        initialSettings: const AppSettings(
          themePreference: AppThemePreference.light,
          themePalette: AppThemePalette.green,
          workDayStartHour: 8,
          workDayEndHour: 19,
          minimumFreeSlotMinutes: 45,
          defaultReminderPreset: ReminderLeadTimePreset.day1,
          notificationsEnabled: false,
        ),
      );

      await controller.resetSettings();

      expect(themeController.preference, AppThemePreference.dark);
      expect(themeController.palette, AppThemePalette.blue);
      expect(controller.workDayStartHour, AppSettings.defaultWorkDayStartHour);
      expect(controller.workDayEndHour, AppSettings.defaultWorkDayEndHour);
      expect(
        controller.minimumFreeSlotMinutes,
        AppSettings.defaultMinimumFreeSlotMinutes,
      );
      expect(
        controller.defaultReminderPreset,
        AppSettings.defaultReminderLeadTimePreset,
      );
      expect(
        controller.notificationsEnabled,
        AppSettings.defaultNotificationsEnabled,
      );
      expect(notifications.successEvents, hasLength(1));
    },
  );

  test(
    'ошибка reset settings откатывает состояние и показывает error notification',
    () async {
      final RecordingAppLogger logger = RecordingAppLogger();
      final RecordingAppNotificationService notifications =
          RecordingAppNotificationService();
      final FakeSettingsRepository repository = FakeSettingsRepository(
        initialSettings: const AppSettings(
          workDayStartHour: 8,
          workDayEndHour: 19,
          minimumFreeSlotMinutes: 45,
          defaultReminderPreset: ReminderLeadTimePreset.day1,
          notificationsEnabled: false,
        ),
        failOnReset: true,
      );
      final ThemeController themeController = ThemeController(
        logger: AppLogger(),
        notificationService: RecordingAppNotificationService(),
        repository: FakeSettingsRepository(),
        initialPreference: AppThemePreference.light,
        initialPalette: AppThemePalette.green,
      );
      final SettingsController controller = SettingsController(
        themeController: themeController,
        logger: logger,
        notificationService: notifications,
        repository: repository,
        initialSettings: const AppSettings(
          themePreference: AppThemePreference.light,
          themePalette: AppThemePalette.green,
          workDayStartHour: 8,
          workDayEndHour: 19,
          minimumFreeSlotMinutes: 45,
          defaultReminderPreset: ReminderLeadTimePreset.day1,
          notificationsEnabled: false,
        ),
      );

      await controller.resetSettings();

      expect(themeController.preference, AppThemePreference.light);
      expect(themeController.palette, AppThemePalette.green);
      expect(controller.workDayStartHour, 8);
      expect(controller.workDayEndHour, 19);
      expect(controller.minimumFreeSlotMinutes, 45);
      expect(controller.defaultReminderPreset, ReminderLeadTimePreset.day1);
      expect(controller.notificationsEnabled, isFalse);
      expect(notifications.errorEvents, hasLength(1));
      expect(logger.errorEvents, hasLength(1));
    },
  );
}

ThemeController _buildThemeController() {
  return ThemeController(
    logger: AppLogger(),
    notificationService: RecordingAppNotificationService(),
    repository: FakeSettingsRepository(),
    initialPreference: AppThemePreference.dark,
    initialPalette: AppThemePalette.blue,
  );
}

class RecordingAppNotificationService extends AppNotificationService {
  RecordingAppNotificationService() : super(logger: AppLogger());

  final List<({String title, String message})> successEvents =
      <({String title, String message})>[];
  final List<({String title, String message})> errorEvents =
      <({String title, String message})>[];

  @override
  void show(NotificationConfig config) {
    switch (config.type) {
      case NotificationType.success:
        successEvents.add((title: config.title, message: config.message ?? ''));
      case NotificationType.error:
        errorEvents.add((title: config.title, message: config.message ?? ''));
    }
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

class RecordingAppLogger extends AppLogger {
  final List<String> infoEvents = <String>[];
  final List<String> warningEvents = <String>[];
  final List<String> errorEvents = <String>[];

  @override
  void info(String message, {String? tag, Object? context}) {
    infoEvents.add(message);
  }

  @override
  void warning(String message, {String? tag, Object? context}) {
    warningEvents.add(message);
  }

  @override
  void error(
    String message, {
    String? tag,
    Object? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    errorEvents.add(message);
  }
}

class FakeSettingsRepository implements AppSettingsRepository {
  FakeSettingsRepository({
    AppSettings? initialSettings,
    this.failOnSaveBounds = false,
    this.failOnReset = false,
  }) : _settings = initialSettings ?? const AppSettings();

  AppSettings _settings;
  final bool failOnSaveBounds;
  final bool failOnReset;

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
    if (failOnSaveBounds) {
      throw StateError('bounds save failed');
    }

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
    if (failOnReset) {
      throw StateError('reset failed');
    }

    _settings = const AppSettings();
  }
}
