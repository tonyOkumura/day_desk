import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../features/settings/domain/entities/app_theme_palette.dart';
import '../../features/settings/domain/entities/app_theme_preference.dart';
import '../../features/settings/domain/repositories/app_settings_repository.dart';

class ThemeController extends GetxController {
  ThemeController({
    required AppSettingsRepository repository,
    required AppThemePreference initialPreference,
    required AppThemePalette initialPalette,
  })  : _repository = repository,
        _preference = initialPreference.obs,
        _palette = initialPalette.obs;

  final AppSettingsRepository _repository;
  final Rx<AppThemePreference> _preference;
  final Rx<AppThemePalette> _palette;

  AppThemePreference get preference => _preference.value;
  AppThemePalette get palette => _palette.value;
  ThemeMode get themeMode => _preference.value.toThemeMode();

  Future<void> setPreference(AppThemePreference preference) async {
    if (_preference.value == preference) {
      return;
    }

    _preference.value = preference;
    await _repository.saveThemePreference(preference);
  }

  Future<void> setPalette(AppThemePalette palette) async {
    if (_palette.value == palette) {
      return;
    }

    _palette.value = palette;
    await _repository.saveThemePalette(palette);
  }
}
