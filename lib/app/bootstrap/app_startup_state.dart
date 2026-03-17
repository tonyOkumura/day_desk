import '../../features/settings/domain/entities/app_theme_palette.dart';
import '../../features/settings/domain/entities/app_theme_preference.dart';

class AppStartupState {
  const AppStartupState({
    required this.initialThemePreference,
    required this.initialThemePalette,
  });

  final AppThemePreference initialThemePreference;
  final AppThemePalette initialThemePalette;
}
