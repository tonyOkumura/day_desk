import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/feature_placeholder_view.dart';
import '../controllers/tasks_controller.dart';

class TasksPage extends GetView<TasksController> {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      destination: AppDestination.tasks,
      title: 'Задачи',
      summary: AppDestination.tasks.summary,
      child: FeaturePlaceholderView(
        title: 'Модуль задач',
        summary: 'Этот раздел станет первым полноценным модулем продукта. '
            'Сейчас тут уже есть готовое место в shell и стабильная точка '
            'входа для начала Sprint 1.',
        highlights: controller.highlights,
        nextMilestone: 'Следующим шагом появятся сущности Task, локальное '
            'хранение, экран списка и форма создания и редактирования.',
      ),
    );
  }
}
