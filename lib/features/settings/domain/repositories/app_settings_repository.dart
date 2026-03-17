import '../entities/app_theme_preference.dart';

abstract interface class AppSettingsRepository {
  Future<AppThemePreference> readThemePreference();

  Future<void> saveThemePreference(AppThemePreference preference);
}
