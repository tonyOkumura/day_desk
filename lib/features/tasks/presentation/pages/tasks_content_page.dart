import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/feature_placeholder_view.dart';
import '../../../../app/shell/page_content_frame.dart';
import '../controllers/tasks_controller.dart';

class TasksContentPage extends GetView<TasksController> {
  const TasksContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContentFrame(
      storageKey: AppDestination.tasks.pageStorageKey,
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
