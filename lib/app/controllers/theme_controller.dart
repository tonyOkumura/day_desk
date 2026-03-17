import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../core/logging/app_logger.dart';
import '../../core/notifications/app_notification_service.dart';
import '../../features/settings/domain/entities/app_theme_palette.dart';
import '../../features/settings/domain/entities/app_theme_preference.dart';
import '../../features/settings/domain/repositories/app_settings_repository.dart';

class ThemeController extends GetxController {
  ThemeController({
    required AppLogger logger,
    required AppNotificationService notificationService,
    required AppSettingsRepository repository,
    required AppThemePreference initialPreference,
    required AppThemePalette initialPalette,
  })  : _logger = logger,
        _notificationService = notificationService,
        _repository = repository,
        _preference = initialPreference.obs,
        _palette = initialPalette.obs;

  final AppLogger _logger;
  final AppNotificationService _notificationService;
  final AppSettingsRepository _repository;
  final Rx<AppThemePreference> _preference;
  final Rx<AppThemePalette> _palette;

  AppThemePreference get preference => _preference.value;
  AppThemePalette get palette => _palette.value;
  ThemeMode get themeMode => _preference.value.toThemeMode();

  Future<void> setPreference(AppThemePreference preference) async {
    final AppThemePreference previousPreference = _preference.value;
    if (previousPreference == preference) {
      return;
    }

    _preference.value = preference;

    try {
      await _repository.saveThemePreference(preference);
      _logger.info(
        'Theme mode updated.',
        tag: 'ThemeController',
        context: <String, String>{
          'preference': preference.name,
        },
      );
      _notificationService.showSuccess(
        title: 'Режим темы обновлён',
        message: 'Теперь используется режим "${preference.label}".',
      );
    } catch (error, stackTrace) {
      _preference.value = previousPreference;
      _logger.error(
        'Failed to persist theme mode.',
        tag: 'ThemeController',
        context: <String, String>{
          'attemptedPreference': preference.name,
          'rollbackPreference': previousPreference.name,
        },
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось изменить режим темы',
        message: 'Изменение не сохранилось. Попробуй ещё раз.',
      );
    }
  }

  Future<void> setPalette(AppThemePalette palette) async {
    final AppThemePalette previousPalette = _palette.value;
    if (previousPalette == palette) {
      return;
    }

    _palette.value = palette;

    try {
      await _repository.saveThemePalette(palette);
      _logger.info(
        'Theme palette updated.',
        tag: 'ThemeController',
        context: <String, String>{
          'palette': palette.name,
        },
      );
      _notificationService.showSuccess(
        title: 'Палитра обновлена',
        message: 'Активна палитра "${palette.label}".',
      );
    } catch (error, stackTrace) {
      _palette.value = previousPalette;
      _logger.error(
        'Failed to persist theme palette.',
        tag: 'ThemeController',
        context: <String, String>{
          'attemptedPalette': palette.name,
          'rollbackPalette': previousPalette.name,
        },
        error: error,
        stackTrace: stackTrace,
      );
      _notificationService.showError(
        title: 'Не удалось изменить палитру',
        message: 'Изменение не сохранилось. Попробуй ещё раз.',
      );
    }
  }
}
