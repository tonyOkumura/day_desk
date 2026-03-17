import 'package:get/get.dart';

import '../../features/settings/domain/repositories/app_settings_repository.dart';
import '../bootstrap/app_startup_state.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/theme_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ThemeController>()) {
      Get.put<ThemeController>(
        ThemeController(
          repository: Get.find<AppSettingsRepository>(),
          initialPreference: Get.find<AppStartupState>().initialThemePreference,
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<NavigationController>()) {
      Get.put<NavigationController>(
        NavigationController(),
        permanent: true,
      );
    }
  }
}
