import 'package:get/get.dart';

import '../presentation/controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(DashboardController.new);
  }
}
