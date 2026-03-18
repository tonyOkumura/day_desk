enum ReminderLeadTimePreset {
  none,
  minutes15,
  hour1,
  day1;

  String get label {
    return switch (this) {
      ReminderLeadTimePreset.none => 'Без напоминания',
      ReminderLeadTimePreset.minutes15 => 'За 15 минут',
      ReminderLeadTimePreset.hour1 => 'За 1 час',
      ReminderLeadTimePreset.day1 => 'За 1 день',
    };
  }

  String get taskChipLabel {
    return switch (this) {
      ReminderLeadTimePreset.none => 'Без напоминания',
      ReminderLeadTimePreset.minutes15 => 'Напомнить за 15 мин',
      ReminderLeadTimePreset.hour1 => 'Напомнить за 1 час',
      ReminderLeadTimePreset.day1 => 'Напомнить за 1 день',
    };
  }

  Duration? get leadTime {
    return switch (this) {
      ReminderLeadTimePreset.none => null,
      ReminderLeadTimePreset.minutes15 => const Duration(minutes: 15),
      ReminderLeadTimePreset.hour1 => const Duration(hours: 1),
      ReminderLeadTimePreset.day1 => const Duration(days: 1),
    };
  }

  bool get hasReminder => this != ReminderLeadTimePreset.none;

  DateTime? resolveReminderAt(DateTime? anchor) {
    final Duration? offset = leadTime;
    if (anchor == null || offset == null) {
      return null;
    }

    return anchor.subtract(offset);
  }
}
