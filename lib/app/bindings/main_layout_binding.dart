import 'package:get/get.dart';

import '../../features/availability/bindings/availability_binding.dart';
import '../../features/calendar/bindings/calendar_binding.dart';
import '../../features/dashboard/bindings/dashboard_binding.dart';
import '../../features/map/bindings/map_binding.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/tasks/bindings/tasks_binding.dart';

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    DashboardBinding().dependencies();
    MapBinding().dependencies();
    CalendarBinding().dependencies();
    TasksBinding().dependencies();
    AvailabilityBinding().dependencies();
    SettingsBinding().dependencies();
  }
}
