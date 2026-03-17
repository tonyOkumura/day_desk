import 'package:flutter/material.dart';

enum AppThemePreference {
  system,
  light,
  dark,
}

extension AppThemePreferenceX on AppThemePreference {
  ThemeMode toThemeMode() {
    return switch (this) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
  }

  String get label {
    return switch (this) {
      AppThemePreference.system => 'Системная',
      AppThemePreference.light => 'Светлая',
      AppThemePreference.dark => 'Тёмная',
    };
  }

  String get description {
    return switch (this) {
      AppThemePreference.system =>
        'Подстраивается под системные настройки устройства.',
      AppThemePreference.light =>
        'Светлый режим для дневной работы и ярких окружений.',
      AppThemePreference.dark =>
        'Основной режим Day Desk с контрастными рабочими поверхностями.',
    };
  }

  IconData get icon {
    return switch (this) {
      AppThemePreference.system => Icons.brightness_auto_rounded,
      AppThemePreference.light => Icons.light_mode_rounded,
      AppThemePreference.dark => Icons.dark_mode_rounded,
    };
  }
}
