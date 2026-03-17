import 'package:flutter/material.dart';

import '../routes/app_pages.dart';

enum AppDestination {
  today,
  calendar,
  tasks,
  availability,
  settings,
}

extension AppDestinationX on AppDestination {
  String get route {
    return switch (this) {
      AppDestination.today => AppRoutes.today,
      AppDestination.calendar => AppRoutes.calendar,
      AppDestination.tasks => AppRoutes.tasks,
      AppDestination.availability => AppRoutes.availability,
      AppDestination.settings => AppRoutes.settings,
    };
  }

  String get label {
    return switch (this) {
      AppDestination.today => 'Сегодня',
      AppDestination.calendar => 'Календарь',
      AppDestination.tasks => 'Задачи',
      AppDestination.availability => 'Свободное время',
      AppDestination.settings => 'Настройки',
    };
  }

  IconData get icon {
    return switch (this) {
      AppDestination.today => Icons.dashboard_outlined,
      AppDestination.calendar => Icons.calendar_month_outlined,
      AppDestination.tasks => Icons.checklist_rtl_outlined,
      AppDestination.availability => Icons.schedule_outlined,
      AppDestination.settings => Icons.tune_outlined,
    };
  }

  IconData get selectedIcon {
    return switch (this) {
      AppDestination.today => Icons.dashboard_rounded,
      AppDestination.calendar => Icons.calendar_month_rounded,
      AppDestination.tasks => Icons.checklist_rtl_rounded,
      AppDestination.availability => Icons.schedule_rounded,
      AppDestination.settings => Icons.tune_rounded,
    };
  }

  String get summary {
    return switch (this) {
      AppDestination.today =>
        'Главный сценарий дня и обзор текущего ритма.',
      AppDestination.calendar =>
        'Навигация по датам и обзор плотности расписания.',
      AppDestination.tasks =>
        'Будущий центр управления рабочими и личными задачами.',
      AppDestination.availability =>
        'Экран для понимания свободных окон и возможностей для встреч.',
      AppDestination.settings =>
        'Базовые системные настройки приложения и визуальной среды.',
    };
  }
}
