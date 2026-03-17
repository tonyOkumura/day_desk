import 'package:get/get.dart';

import '../../features/availability/bindings/availability_binding.dart';
import '../../features/availability/presentation/pages/availability_page.dart';
import '../../features/calendar/bindings/calendar_binding.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/dashboard/bindings/dashboard_binding.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/tasks/bindings/tasks_binding.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';

abstract final class AppRoutes {
  static const String today = '/today';
  static const String calendar = '/calendar';
  static const String tasks = '/tasks';
  static const String availability = '/availability';
  static const String settings = '/settings';
}

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.today;

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.today,
      page: DashboardPage.new,
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: CalendarPage.new,
      binding: CalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.tasks,
      page: TasksPage.new,
      binding: TasksBinding(),
    ),
    GetPage(
      name: AppRoutes.availability,
      page: AvailabilityPage.new,
      binding: AvailabilityBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: SettingsPage.new,
      binding: SettingsBinding(),
    ),
  ];
}
