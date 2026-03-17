import 'package:get/get.dart';

import '../../core/logging/app_logger.dart';
import '../../core/notifications/app_notification_service.dart';
import '../../features/settings/domain/repositories/app_settings_repository.dart';
import '../bootstrap/app_startup_state.dart';
import '../controllers/main_layout_controller.dart';
import '../controllers/theme_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppNotificationService>()) {
      Get.put<AppNotificationService>(
        AppNotificationService(
          logger: Get.find<AppLogger>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<ThemeController>()) {
      Get.put<ThemeController>(
        ThemeController(
          logger: Get.find<AppLogger>(),
          notificationService: Get.find<AppNotificationService>(),
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
