import '../../../../core/reminders/reminder_lead_time_preset.dart';
import 'app_theme_palette.dart';
import 'app_theme_preference.dart';

class AppSettings {
  const AppSettings({
    this.themePreference = AppThemePreference.dark,
    this.themePalette = AppThemePalette.blue,
    this.workDayStartHour = defaultWorkDayStartHour,
    this.workDayEndHour = defaultWorkDayEndHour,
    this.minimumFreeSlotMinutes = defaultMinimumFreeSlotMinutes,
    this.defaultReminderPreset = defaultReminderLeadTimePreset,
    this.notificationsEnabled = defaultNotificationsEnabled,
  }) : assert(workDayStartHour >= 0 && workDayStartHour <= 22),
       assert(workDayEndHour >= 1 && workDayEndHour <= 23),
       assert(workDayStartHour < workDayEndHour),
       assert(minimumFreeSlotMinutes > 0);

  static const int defaultWorkDayStartHour = 9;
  static const int defaultWorkDayEndHour = 18;
  static const int defaultMinimumFreeSlotMinutes = 30;
  static const ReminderLeadTimePreset defaultReminderLeadTimePreset =
      ReminderLeadTimePreset.minutes15;
  static const bool defaultNotificationsEnabled = true;

  final AppThemePreference themePreference;
  final AppThemePalette themePalette;
  final int workDayStartHour;
  final int workDayEndHour;
  final int minimumFreeSlotMinutes;
  final ReminderLeadTimePreset defaultReminderPreset;
  final bool notificationsEnabled;

  AppSettings copyWith({
    AppThemePreference? themePreference,
    AppThemePalette? themePalette,
    int? workDayStartHour,
    int? workDayEndHour,
    int? minimumFreeSlotMinutes,
    ReminderLeadTimePreset? defaultReminderPreset,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      themePalette: themePalette ?? this.themePalette,
      workDayStartHour: workDayStartHour ?? this.workDayStartHour,
      workDayEndHour: workDayEndHour ?? this.workDayEndHour,
      minimumFreeSlotMinutes:
          minimumFreeSlotMinutes ?? this.minimumFreeSlotMinutes,
      defaultReminderPreset:
          defaultReminderPreset ?? this.defaultReminderPreset,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
