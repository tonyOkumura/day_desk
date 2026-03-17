import 'package:get/get.dart';

import '../../../core/logging/app_logger.dart';
import '../presentation/controllers/places_map_controller.dart';

class MapBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PlacesMapController>()) {
      Get.put<PlacesMapController>(
        PlacesMapController(logger: Get.find<AppLogger>()),
        permanent: true,
      );
    }
  }
}
