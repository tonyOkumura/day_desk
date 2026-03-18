import 'package:isar/isar.dart';

import '../../../../core/reminders/reminder_lead_time_preset.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/app_theme_palette.dart';
import '../../domain/entities/app_theme_preference.dart';

part 'app_settings_local_model.g.dart';

@collection
class AppSettingsLocalModel {
  AppSettingsLocalModel();

  static const int singletonId = 0;

  Id id = singletonId;

  @Enumerated(EnumType.name)
  AppThemePreference themePreference = AppThemePreference.dark;

  @Enumerated(EnumType.name)
  AppThemePalette themePalette = AppThemePalette.blue;

  int workDayStartHour = AppSettings.defaultWorkDayStartHour;

  int workDayEndHour = AppSettings.defaultWorkDayEndHour;

  int minimumFreeSlotMinutes = AppSettings.defaultMinimumFreeSlotMinutes;

  @Enumerated(EnumType.name)
  ReminderLeadTimePreset defaultReminderPreset =
      AppSettings.defaultReminderLeadTimePreset;

  bool notificationsEnabled = AppSettings.defaultNotificationsEnabled;

  DateTime updatedAt = DateTime.now();
}
