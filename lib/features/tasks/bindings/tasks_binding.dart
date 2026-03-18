import 'package:get/get.dart';

import '../../../core/date/app_date_formatter.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/notifications/app_notification_service.dart';
import '../../settings/domain/repositories/app_settings_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../presentation/controllers/tasks_controller.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TasksController>()) {
      Get.put<TasksController>(
        TasksController(
          repository: Get.find<TaskRepository>(),
          settingsRepository: Get.find<AppSettingsRepository>(),
          dateFormatter: Get.find<AppDateFormatter>(),
          logger: Get.find<AppLogger>(),
          notificationService: Get.find<AppNotificationService>(),
        ),
        permanent: true,
      );
    }
  }
}
