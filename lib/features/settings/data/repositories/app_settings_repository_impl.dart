import '../../domain/entities/app_settings.dart';
import '../../domain/entities/app_theme_palette.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../datasources/app_settings_local_data_source.dart';
import '../models/app_settings_local_model.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl(this._localDataSource);

  final AppSettingsLocalDataSource _localDataSource;

  @override
  Future<AppSettings> readSettings() async {
    final AppSettingsLocalModel? settings = await _localDataSource
        .readSettings();
    if (settings == null) {
      return const AppSettings();
    }

    return AppSettings(
      themePreference: settings.themePreference,
      themePalette: settings.themePalette,
      workDayStartHour: settings.workDayStartHour,
      workDayEndHour: settings.workDayEndHour,
      minimumFreeSlotMinutes: settings.minimumFreeSlotMinutes,
      notificationsEnabled: settings.notificationsEnabled,
    );
  }

  @override
  Future<void> saveThemePreference(AppThemePreference preference) {
    return _localDataSource.saveThemePreference(preference);
  }

  @override
  Future<void> saveThemePalette(AppThemePalette palette) {
    return _localDataSource.saveThemePalette(palette);
  }

  @override
  Future<void> saveWorkDayBounds({
    required int startHour,
    required int endHour,
  }) {
    return _localDataSource.saveWorkDayBounds(
      startHour: startHour,
      endHour: endHour,
    );
  }

  @override
  Future<void> saveMinimumFreeSlotMinutes(int minutes) {
    return _localDataSource.saveMinimumFreeSlotMinutes(minutes);
  }

  @override
  Future<void> saveNotificationsEnabled(bool enabled) {
    return _localDataSource.saveNotificationsEnabled(enabled);
  }
}
