import 'package:get/get.dart';

import '../presentation/controllers/tasks_controller.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TasksController>(TasksController.new);
  }
}
