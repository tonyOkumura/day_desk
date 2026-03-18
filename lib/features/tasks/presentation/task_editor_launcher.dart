import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../core/config/app_breakpoints.dart';
import '../../../core/date/app_date_formatter.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/notifications/app_notification_service.dart';
import '../../settings/domain/entities/app_settings.dart';
import '../../settings/domain/repositories/app_settings_repository.dart';
import '../domain/entities/task.dart';
import '../domain/repositories/task_repository.dart';
import 'controllers/task_editor_controller.dart';
import 'widgets/task_editor_sheet.dart';

Future<void> openTaskEditorFlow(
  BuildContext context, {
  Task? task,
  required DateTime initialDate,
}) async {
  final AppSettings settings = await Get.find<AppSettingsRepository>()
      .readSettings();
  if (!context.mounted) {
    return;
  }

  final TaskEditorController editor = TaskEditorController(
    repository: Get.find<TaskRepository>(),
    dateFormatter: Get.find<AppDateFormatter>(),
    logger: Get.find<AppLogger>(),
    notificationService: Get.find<AppNotificationService>(),
    defaultReminderPreset: settings.defaultReminderPreset,
    initialTask: task,
    initialDate: initialDate,
  );

  final bool compact =
      MediaQuery.sizeOf(context).width < AppBreakpoints.compactNavigation;

  if (compact) {
    await Navigator.of(context).push<Task>(
      MaterialPageRoute<Task>(
        builder: (BuildContext context) => TaskEditorPage(controller: editor),
        fullscreenDialog: true,
      ),
    );
    return;
  }

  await showDialog<Task>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return TaskEditorDialog(controller: editor);
    },
  );
}
