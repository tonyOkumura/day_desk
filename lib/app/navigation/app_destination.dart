import 'package:flutter/material.dart';

enum AppDestination {
  today(
    route: '/today',
    label: 'Сегодня',
    title: 'Сегодня',
    summary: 'Главный сценарий дня и обзор текущего ритма.',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard_rounded,
    pageStorageKey: 'today-tab',
  ),
  map(
    route: '/map',
    label: 'Карта',
    title: 'Карта',
    summary: 'Стартовый картографический экран Москвы и будущих мест на день.',
    icon: Icons.map_outlined,
    selectedIcon: Icons.map_rounded,
    pageStorageKey: 'map-tab',
  ),
  calendar(
    route: '/calendar',
    label: 'Календарь',
    title: 'Календарь',
    summary: 'Навигация по датам и обзор плотности расписания.',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month_rounded,
    pageStorageKey: 'calendar-tab',
  ),
  tasks(
    route: '/tasks',
    label: 'Задачи',
    title: 'Задачи',
    summary: 'Будущий центр управления рабочими и личными задачами.',
    icon: Icons.checklist_rtl_outlined,
    selectedIcon: Icons.checklist_rtl_rounded,
    pageStorageKey: 'tasks-tab',
  ),
  availability(
    route: '/availability',
    label: 'Свободное время',
    title: 'Свободное время',
    summary: 'Экран для понимания свободных окон и возможностей для встреч.',
    icon: Icons.schedule_outlined,
    selectedIcon: Icons.schedule_rounded,
    pageStorageKey: 'availability-tab',
  ),
  settings(
    route: '/settings',
    label: 'Настройки',
    title: 'Настройки',
    summary: 'Базовые системные настройки приложения и визуальной среды.',
    icon: Icons.tune_outlined,
    selectedIcon: Icons.tune_rounded,
    pageStorageKey: 'settings-tab',
  );

  const AppDestination({
    required this.route,
    required this.label,
    required this.title,
    required this.summary,
    required this.icon,
    required this.selectedIcon,
    required this.pageStorageKey,
  });

  final String route;
  final String label;
  final String title;
  final String summary;
  final IconData icon;
  final IconData selectedIcon;
  final String pageStorageKey;

  static AppDestination fromRoute(String route) {
    return AppDestination.values.firstWhere(
      (AppDestination destination) => destination.route == route,
      orElse: () => AppDestination.today,
    );
  }
}
