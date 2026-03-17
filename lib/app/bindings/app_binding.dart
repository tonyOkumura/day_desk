import 'package:get/get.dart';

import '../../features/settings/domain/repositories/app_settings_repository.dart';
import '../bootstrap/app_startup_state.dart';
import '../controllers/main_layout_controller.dart';
import '../controllers/theme_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ThemeController>()) {
      Get.put<ThemeController>(
        ThemeController(
          repository: Get.find<AppSettingsRepository>(),
          initialPreference: Get.find<AppStartupState>().initialThemePreference,
          initialPalette: Get.find<AppStartupState>().initialThemePalette,
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<MainLayoutController>()) {
      Get.put<MainLayoutController>(
        MainLayoutController(),
        permanent: true,
      );
    }
  }
}
