import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/feature_placeholder_view.dart';
import '../../../../app/shell/page_content_frame.dart';
import '../controllers/dashboard_controller.dart';

class DashboardContentPage extends GetView<DashboardController> {
  const DashboardContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContentFrame(
      storageKey: AppDestination.today.pageStorageKey,
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
