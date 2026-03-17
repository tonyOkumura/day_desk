import 'package:get/get.dart';

import '../presentation/controllers/availability_controller.dart';

class AvailabilityBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AvailabilityController>()) {
      Get.put<AvailabilityController>(
        AvailabilityController(),
        permanent: true,
      );
    }
  }
}
