import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/feature_placeholder_view.dart';
import '../controllers/availability_controller.dart';

class AvailabilityPage extends GetView<AvailabilityController> {
  const AvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      destination: AppDestination.availability,
      title: 'Свободное время',
      summary: AppDestination.availability.summary,
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
