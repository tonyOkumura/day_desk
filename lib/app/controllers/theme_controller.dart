import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../features/settings/domain/entities/app_theme_preference.dart';
import '../../features/settings/domain/repositories/app_settings_repository.dart';

class ThemeController extends GetxController {
  ThemeController({
    required AppSettingsRepository repository,
    required AppThemePreference initialPreference,
  })  : _repository = repository,
        _preference = initialPreference.obs;

  final AppSettingsRepository _repository;
  final Rx<AppThemePreference> _preference;

  AppThemePreference get preference => _preference.value;
  ThemeMode get themeMode => _preference.value.toThemeMode();

  Future<void> setPreference(AppThemePreference preference) async {
    if (_preference.value == preference) {
      return;
    }

    _preference.value = preference;
    await _repository.saveThemePreference(preference);
  }
}
