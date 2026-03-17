import 'package:day_desk/app/controllers/theme_controller.dart';
import 'package:day_desk/core/logging/app_logger.dart';
import 'package:day_desk/core/notifications/app_notification_service.dart';
import 'package:day_desk/core/notifications/notification_config.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_palette.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_preference.dart';
import 'package:day_desk/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('успешная смена режима темы показывает success notification', () async {
    final RecordingAppLogger logger = RecordingAppLogger();
    final RecordingAppNotificationService notifications =
        RecordingAppNotificationService();
    final FakeSettingsRepository repository = FakeSettingsRepository();
    final ThemeController controller = ThemeController(
      logger: logger,
      notificationService: notifications,
      repository: repository,
      initialPreference: AppThemePreference.dark,
      initialPalette: AppThemePalette.blue,
    );

    await controller.setPreference(AppThemePreference.light);

    expect(controller.preference, AppThemePreference.light);
    expect(repository.savedPreference, AppThemePreference.light);
    expect(notifications.successEvents, hasLength(1));
    expect(notifications.errorEvents, isEmpty);
  });

  test('успешная смена палитры показывает success notification', () async {
    final RecordingAppLogger logger = RecordingAppLogger();
    final RecordingAppNotificationService notifications =
        RecordingAppNotificationService();
    final FakeSettingsRepository repository = FakeSettingsRepository();
    final ThemeController controller = ThemeController(
      logger: logger,
      notificationService: notifications,
      repository: repository,
      initialPreference: AppThemePreference.dark,
      initialPalette: AppThemePalette.blue,
    );

    await controller.setPalette(AppThemePalette.green);

    expect(controller.palette, AppThemePalette.green);
    expect(repository.savedPalette, AppThemePalette.green);
    expect(notifications.successEvents, hasLength(1));
    expect(notifications.errorEvents, isEmpty);
  });

  test('повторный выбор активного режима темы не создаёт уведомление', () async {
    final RecordingAppLogger logger = RecordingAppLogger();
    final RecordingAppNotificationService notifications =
        RecordingAppNotificationService();
    final FakeSettingsRepository repository = FakeSettingsRepository();
    final ThemeController controller = ThemeController(
      logger: logger,
      notificationService: notifications,
      repository: repository,
      initialPreference: AppThemePreference.dark,
      initialPalette: AppThemePalette.blue,
    );

    await controller.setPreference(AppThemePreference.dark);

    expect(notifications.successEvents, isEmpty);
    expect(notifications.errorEvents, isEmpty);
    expect(logger.infoEvents, isEmpty);
  });

  test('повторный выбор активной палитры не создаёт уведомление', () async {
    final RecordingAppLogger logger = RecordingAppLogger();
    final RecordingAppNotificationService notifications =
        RecordingAppNotificationService();
    final FakeSettingsRepository repository = FakeSettingsRepository();
    final ThemeController controller = ThemeController(
      logger: logger,
      notificationService: notifications,
      repository: repository,
      initialPreference: AppThemePreference.dark,
      initialPalette: AppThemePalette.blue,
    );

    await controller.setPalette(AppThemePalette.blue);

    expect(notifications.successEvents, isEmpty);
    expect(notifications.errorEvents, isEmpty);
    expect(logger.infoEvents, isEmpty);
  });

  test('ошибка сохранения режима темы откатывает состояние и логируется', () async {
    final RecordingAppLogger logger = RecordingAppLogger();
    final RecordingAppNotificationService notifications =
        RecordingAppNotificationService();
    final FakeSettingsRepository repository = FakeSettingsRepository(
      failOnSavePreference: true,
    );
    final ThemeController controller = ThemeController(
      logger: logger,
      notificationService: notifications,
      repository: repository,
      initialPreference: AppThemePreference.dark,
      initialPalette: AppThemePalette.blue,
    );

    await controller.setPreference(AppThemePreference.light);

    expect(controller.preference, AppThemePreference.dark);
    expect(notifications.successEvents, isEmpty);
    expect(notifications.errorEvents, hasLength(1));
    expect(logger.errorEvents, hasLength(1));
  });

  test('ошибка сохранения палитры откатывает состояние и логируется', () async {
    final RecordingAppLogger logger = RecordingAppLogger();
    final RecordingAppNotificationService notifications =
        RecordingAppNotificationService();
    final FakeSettingsRepository repository = FakeSettingsRepository(
      failOnSavePalette: true,
    );
    final ThemeController controller = ThemeController(
      logger: logger,
      notificationService: notifications,
      repository: repository,
      initialPreference: AppThemePreference.dark,
      initialPalette: AppThemePalette.blue,
    );

    await controller.setPalette(AppThemePalette.green);

    expect(controller.palette, AppThemePalette.blue);
    expect(notifications.successEvents, isEmpty);
    expect(notifications.errorEvents, hasLength(1));
    expect(logger.errorEvents, hasLength(1));
  });
}

class RecordingAppNotificationService extends AppNotificationService {
  RecordingAppNotificationService()
      : super(
          logger: AppLogger(),
        );

  final List<({String title, String message})> successEvents =
      <({String title, String message})>[];
  final List<({String title, String message})> errorEvents =
      <({String title, String message})>[];

  @override
  void show(NotificationConfig config) {
    switch (config.type) {
      case NotificationType.success:
        successEvents.add((
          title: config.title,
          message: config.message ?? '',
        ));
      case NotificationType.error:
        errorEvents.add((
          title: config.title,
          message: config.message ?? '',
        ));
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
  void info(
    String message, {
    String? tag,
    Object? context,
  }) {
    infoEvents.add(message);
  }

  @override
  void warning(
    String message, {
    String? tag,
    Object? context,
  }) {
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
    this.failOnSavePreference = false,
    this.failOnSavePalette = false,
  });

  final bool failOnSavePreference;
  final bool failOnSavePalette;

  AppThemePreference savedPreference = AppThemePreference.dark;
  AppThemePalette savedPalette = AppThemePalette.blue;

  @override
  Future<AppThemePreference> readThemePreference() async {
    return savedPreference;
  }

  @override
  Future<AppThemePalette> readThemePalette() async {
    return savedPalette;
  }

  @override
  Future<void> saveThemePreference(AppThemePreference preference) async {
    if (failOnSavePreference) {
      throw StateError('preference save failed');
    }

    savedPreference = preference;
  }

  @override
  Future<void> saveThemePalette(AppThemePalette palette) async {
    if (failOnSavePalette) {
      throw StateError('palette save failed');
    }

    savedPalette = palette;
  }
}
