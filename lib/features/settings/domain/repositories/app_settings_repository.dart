import '../entities/app_settings.dart';
import '../entities/app_theme_palette.dart';
import '../entities/app_theme_preference.dart';

abstract interface class AppSettingsRepository {
  Future<AppSettings> readSettings();

  Future<void> saveThemePreference(AppThemePreference preference);

  Future<void> saveThemePalette(AppThemePalette palette);

  Future<void> saveWorkDayBounds({
    required int startHour,
    required int endHour,
  });

  Future<void> saveMinimumFreeSlotMinutes(int minutes);

  Future<void> saveNotificationsEnabled(bool enabled);

  Future<void> resetSettings();
}
