import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/feature_placeholder_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      destination: AppDestination.today,
      title: 'Сегодня',
      summary: AppDestination.today.summary,
      child: FeaturePlaceholderView(
        title: 'Главный экран дня',
        summary: 'Здесь будет собираться единая картина дня: события, задачи, '
            'просроченные элементы и свободные окна. Пока экран работает как '
            'центральная точка Sprint 0.',
        highlights: controller.highlights,
        nextMilestone: 'На Sprint 1 и следующих спринтах этот экран начнет '
            'получать реальные данные из модулей задач и событий.',
      ),
    );
  }
}
