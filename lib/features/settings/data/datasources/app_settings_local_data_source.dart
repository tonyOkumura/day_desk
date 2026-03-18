import 'package:isar/isar.dart';

import '../../../../core/reminders/reminder_lead_time_preset.dart';
import '../../domain/entities/app_theme_palette.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../models/app_settings_local_model.dart';

class AppSettingsLocalDataSource {
  AppSettingsLocalDataSource(this._isar);

  final Isar _isar;

  Future<AppSettingsLocalModel?> readSettings() {
    return _isar.appSettingsLocalModels.get(AppSettingsLocalModel.singletonId);
  }

  Future<void> saveThemePreference(AppThemePreference preference) async {
    await _saveSettings((AppSettingsLocalModel settings) {
      settings.themePreference = preference;
    });
  }

  Future<void> saveThemePalette(AppThemePalette palette) async {
    await _saveSettings((AppSettingsLocalModel settings) {
      settings.themePalette = palette;
    });
  }

  Future<void> saveWorkDayBounds({
    required int startHour,
    required int endHour,
  }) async {
    await _saveSettings((AppSettingsLocalModel settings) {
      settings.workDayStartHour = startHour;
      settings.workDayEndHour = endHour;
    });
  }

  Future<void> saveMinimumFreeSlotMinutes(int minutes) async {
    await _saveSettings((AppSettingsLocalModel settings) {
      settings.minimumFreeSlotMinutes = minutes;
    });
  }

  Future<void> saveDefaultReminderPreset(ReminderLeadTimePreset preset) async {
    await _saveSettings((AppSettingsLocalModel settings) {
      settings.defaultReminderPreset = preset;
    });
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _saveSettings((AppSettingsLocalModel settings) {
      settings.notificationsEnabled = enabled;
    });
  }

  Future<void> resetSettings() async {
    final AppSettingsLocalModel settings = AppSettingsLocalModel()
      ..updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.appSettingsLocalModels.put(settings);
    });
  }

  Future<void> _saveSettings(
    void Function(AppSettingsLocalModel settings) update,
  ) async {
    final AppSettingsLocalModel settings =
        await readSettings() ?? AppSettingsLocalModel();

    update(settings);
    settings.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.appSettingsLocalModels.put(settings);
    });
  }
}
