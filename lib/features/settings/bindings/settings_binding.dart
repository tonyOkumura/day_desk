import 'package:get/get.dart';

import '../../../app/bootstrap/app_startup_state.dart';
import '../../../app/controllers/theme_controller.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/notifications/app_notification_service.dart';
import '../domain/repositories/app_settings_repository.dart';
import '../presentation/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SettingsController>()) {
      Get.put<SettingsController>(
        SettingsController(
          themeController: Get.find<ThemeController>(),
          logger: Get.find<AppLogger>(),
          notificationService: Get.find<AppNotificationService>(),
          repository: Get.find<AppSettingsRepository>(),
          initialSettings: Get.find<AppStartupState>().initialSettings,
        ),
        permanent: true,
      );
    }
  }
}
