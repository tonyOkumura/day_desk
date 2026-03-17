import 'package:get/get.dart';

import '../../../../app/controllers/theme_controller.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/notifications/app_notification_service.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/app_theme_palette.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../../domain/repositories/app_settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController({
    required ThemeController themeController,
    required AppLogger logger,
    required AppNotificationService notificationService,
    required AppSettingsRepository repository,
    required AppSettings initialSettings,
  }) : _themeController = themeController,
       _logger = logger,
       _notificationService = notificationService,
       _repository = repository,
       _settings = initialSettings.obs;

  static const List<int> workHourOptions = <int>[
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
  ];
  static const List<int> freeSlotDurationOptions = <int>[
    15,
    30,
    45,
    60,
    90,
    120,
  ];

  final ThemeController _themeController;
  final AppLogger _logger;
  final AppNotificationService _notificationService;
  final AppSettingsRepository _repository;
  final Rx<AppSettings> _settings;

  List<AppThemePreference> get preferences => AppThemePreference.values;
  List<AppThemePalette> get palettes => AppThemePalette.values;

  AppThemePreference get currentPreference => _themeController.preference;
  AppThemePalette get currentPalette => _themeController.palette;
  AppSettings get currentSettings => _settings.value;
  int get workDayStartHour => _settings.value.workDayStartHour;
  int get workDayEndHour => _settings.value.workDayEndHour;
  int get minimumFreeSlotMinutes => _settings.value.minimumFreeSlotMinutes;
  bool get notificationsEnabled => _settings.value.notificationsEnabled;
  List<int> get availableStartHourOptions {
    return workHourOptions
        .where((int hour) => hour < workDayEndHour)
        .toList(growable: false);
  }

  List<int> get availableEndHourOptions {
    return workHourOptions
        .where((int hour) => hour > workDayStartHour)
        .toList(growable: false);
  }

  Future<void> selectTheme(AppThemePreference preference) {
    return _themeController.setPreference(preference);
  }

  Future<void> selectPalette(AppThemePalette palette) {
    return _themeController.setPalette(palette);
  }

  Future<void> setWorkDayStartHour(int hour) async {
    if (hour == workDayStartHour || hour >= workDayEndHour) {
      return;
    }

    final AppSettings previousSettings = _settings.value;
    final AppSettings nextSettings = previousSettings.copyWith(
      workDayStartHour: hour,
    );
    _settings.value = nextSettings;

    try {
      await _repository.saveWorkDayBounds(
        startHour: hour,
        endHour: nextSettings.workDayEndHour,
      );
      _logger.info(
        'Work day start updated.',
        tag: 'SettingsController',
        context: <String, int>{
          'startHour': hour,
          'endHour': nextSettings.workDayEndHour,
        },
      );
    } catch (error, stackTrace) {
      _settings.value = previousSettings;
      _logger.error(
        'Failed to persist work day start.',
        tag: 'SettingsController',
        context: <String, int>{
          'attemptedStartHour': hour,
          'rollbackStartHour': previousSettings.workDayStartHour,
        },
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось обновить начало дня',
        message: 'Изменение не сохранилось. Попробуй ещё раз.',
      );
    }
  }

  Future<void> setWorkDayEndHour(int hour) async {
    if (hour == workDayEndHour || hour <= workDayStartHour) {
      return;
    }

    final AppSettings previousSettings = _settings.value;
    final AppSettings nextSettings = previousSettings.copyWith(
      workDayEndHour: hour,
    );
    _settings.value = nextSettings;

    try {
      await _repository.saveWorkDayBounds(
        startHour: nextSettings.workDayStartHour,
        endHour: hour,
      );
      _logger.info(
        'Work day end updated.',
        tag: 'SettingsController',
        context: <String, int>{
          'startHour': nextSettings.workDayStartHour,
          'endHour': hour,
        },
      );
    } catch (error, stackTrace) {
      _settings.value = previousSettings;
      _logger.error(
        'Failed to persist work day end.',
        tag: 'SettingsController',
        context: <String, int>{
          'attemptedEndHour': hour,
          'rollbackEndHour': previousSettings.workDayEndHour,
        },
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось обновить конец дня',
        message: 'Изменение не сохранилось. Попробуй ещё раз.',
      );
    }
  }

  Future<void> setMinimumFreeSlotMinutes(int minutes) async {
    if (minutes == minimumFreeSlotMinutes) {
      return;
    }

    final AppSettings previousSettings = _settings.value;
    final AppSettings nextSettings = previousSettings.copyWith(
      minimumFreeSlotMinutes: minutes,
    );
    _settings.value = nextSettings;

    try {
      await _repository.saveMinimumFreeSlotMinutes(minutes);
      _logger.info(
        'Minimum free slot updated.',
        tag: 'SettingsController',
        context: <String, int>{'minutes': minutes},
      );
    } catch (error, stackTrace) {
      _settings.value = previousSettings;
      _logger.error(
        'Failed to persist minimum free slot.',
        tag: 'SettingsController',
        context: <String, int>{
          'attemptedMinutes': minutes,
          'rollbackMinutes': previousSettings.minimumFreeSlotMinutes,
        },
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось обновить длительность окна',
        message: 'Изменение не сохранилось. Попробуй ещё раз.',
      );
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled == notificationsEnabled) {
      return;
    }

    final AppSettings previousSettings = _settings.value;
    final AppSettings nextSettings = previousSettings.copyWith(
      notificationsEnabled: enabled,
    );
    _settings.value = nextSettings;

    try {
      await _repository.saveNotificationsEnabled(enabled);
      _logger.info(
        'Notifications preference updated.',
        tag: 'SettingsController',
        context: <String, bool>{'notificationsEnabled': enabled},
      );
    } catch (error, stackTrace) {
      _settings.value = previousSettings;
      _logger.error(
        'Failed to persist notifications preference.',
        tag: 'SettingsController',
        context: <String, bool>{
          'attemptedNotificationsEnabled': enabled,
          'rollbackNotificationsEnabled': previousSettings.notificationsEnabled,
        },
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось обновить напоминания',
        message: 'Изменение не сохранилось. Попробуй ещё раз.',
      );
    }
  }
}
