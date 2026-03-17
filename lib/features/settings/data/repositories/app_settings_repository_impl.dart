import '../../domain/entities/app_theme_preference.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../datasources/app_settings_local_data_source.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl(this._localDataSource);

  final AppSettingsLocalDataSource _localDataSource;

  @override
  Future<AppThemePreference> readThemePreference() async {
    final settings = await _localDataSource.readSettings();
    return settings?.themePreference ?? AppThemePreference.dark;
  }

  @override
  Future<void> saveThemePreference(AppThemePreference preference) {
    return _localDataSource.saveThemePreference(preference);
  }
}
