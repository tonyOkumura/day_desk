import 'package:get/get.dart';

import '../presentation/controllers/calendar_controller.dart';

class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CalendarController>()) {
      Get.put<CalendarController>(
        CalendarController(),
        permanent: true,
      );
    }
  }
}
