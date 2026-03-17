import 'package:isar/isar.dart';

import '../../domain/entities/app_theme_preference.dart';
import '../models/app_settings_local_model.dart';

class AppSettingsLocalDataSource {
  AppSettingsLocalDataSource(this._isar);

  final Isar _isar;

  Future<AppSettingsLocalModel?> readSettings() {
    return _isar.appSettingsLocalModels.get(AppSettingsLocalModel.singletonId);
  }

  Future<void> saveThemePreference(AppThemePreference preference) async {
    final AppSettingsLocalModel settings =
        await readSettings() ?? AppSettingsLocalModel();

    settings.themePreference = preference;
    settings.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.appSettingsLocalModels.put(settings);
    });
  }
}
