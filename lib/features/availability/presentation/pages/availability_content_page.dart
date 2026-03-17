import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/feature_placeholder_view.dart';
import '../../../../app/shell/page_content_frame.dart';
import '../controllers/availability_controller.dart';

class AvailabilityContentPage extends GetView<AvailabilityController> {
  const AvailabilityContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContentFrame(
      storageKey: AppDestination.availability.pageStorageKey,
      child: FeaturePlaceholderView(
        title: 'Свободные окна',
        summary: 'Здесь позже появится ответ на ключевой вопрос пользователя: '
            'когда он реально свободен. На Sprint 0 экран подготовлен для '
            'будущего алгоритма расчета слотов.',
        highlights: controller.highlights,
        nextMilestone: 'После появления задач, событий и настроек модуль сможет '
            'автоматически считать свободные интервалы по выбранной дате.',
      ),
    );
  }
}
