import '../entities/app_theme_palette.dart';
import '../entities/app_theme_preference.dart';

abstract interface class AppSettingsRepository {
  Future<AppThemePreference> readThemePreference();

  Future<AppThemePalette> readThemePalette();

  Future<void> saveThemePreference(AppThemePreference preference);

  Future<void> saveThemePalette(AppThemePalette palette);
}
