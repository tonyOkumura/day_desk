import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/app_shell.dart';
import '../../../../app/shell/feature_placeholder_view.dart';
import '../controllers/calendar_controller.dart';

class CalendarPage extends GetView<CalendarController> {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      destination: AppDestination.calendar,
      title: 'Календарь',
      summary: AppDestination.calendar.summary,
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
