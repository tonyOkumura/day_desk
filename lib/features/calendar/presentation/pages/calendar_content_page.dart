import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/feature_placeholder_view.dart';
import '../../../../app/shell/page_content_frame.dart';
import '../controllers/calendar_controller.dart';

class CalendarContentPage extends GetView<CalendarController> {
  const CalendarContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContentFrame(
      storageKey: AppDestination.calendar.pageStorageKey,
      child: FeaturePlaceholderView(
        title: 'Модуль календаря',
        summary: 'Месячная сетка, индикаторы дней и список элементов по дате '
            'появятся позже. Сейчас экран закреплен в маршрутизации и готов '
            'к подключению логики.',
        highlights: controller.highlights,
        nextMilestone: 'Следующий шаг для этого раздела — собрать модели дня, '
            'визуальную сетку месяца и привязку к задачам и событиям.',
      ),
    );
  }
}
