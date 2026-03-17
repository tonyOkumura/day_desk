import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/entities/app_theme_palette.dart';
import '../../features/settings/domain/entities/app_theme_preference.dart';

class AppStartupState {
  const AppStartupState({required this.initialSettings});

  final AppSettings initialSettings;

  AppThemePreference get initialThemePreference {
    return initialSettings.themePreference;
  }

  AppThemePalette get initialThemePalette {
    return initialSettings.themePalette;
  }
}
