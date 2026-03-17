import 'package:get/get.dart';

import '../presentation/controllers/tasks_controller.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TasksController>()) {
      Get.put<TasksController>(
        TasksController(),
        permanent: true,
      );
    }
  }
}
