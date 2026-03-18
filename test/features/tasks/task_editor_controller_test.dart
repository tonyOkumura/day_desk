import 'package:day_desk/core/date/app_date_formatter.dart';
import 'package:day_desk/core/logging/app_logger.dart';
import 'package:day_desk/core/notifications/app_notification_service.dart';
import 'package:day_desk/core/notifications/notification_config.dart';
import 'package:day_desk/features/tasks/domain/entities/task.dart';
import 'package:day_desk/features/tasks/domain/entities/task_category.dart';
import 'package:day_desk/features/tasks/domain/entities/task_priority.dart';
import 'package:day_desk/features/tasks/presentation/controllers/task_editor_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../test_helpers/app_test_harness.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting(AppDateFormatter.localeName);
  });

  test('TaskEditorController валидирует пустой title', () async {
    final TaskEditorController controller = TaskEditorController(
      repository: FakeTaskRepository(),
      dateFormatter: AppDateFormatter(),
      logger: AppLogger(),
      notificationService: RecordingTaskNotificationService(),
    );

    final Task? result = await controller.save();

    expect(result, isNull);
    expect(controller.titleError, 'Укажи название задачи');
  });

  test('TaskEditorController очищает время и длительность при all-day', () {
    final TaskEditorController controller = TaskEditorController(
      repository: FakeTaskRepository(),
      dateFormatter: AppDateFormatter(),
      logger: AppLogger(),
      notificationService: RecordingTaskNotificationService(),
    );

    controller.updateStartTime(DateTime(2026, 3, 18, 10, 30));
    controller.updateDurationMinutes(45);
    controller.setAllDay(true);

    expect(controller.startTime, isNull);
    expect(controller.durationMinutes, isNull);
    expect(controller.isAllDay, isTrue);
  });

  test(
    'TaskEditorController сохраняет create и update через один flow',
    () async {
      final FakeTaskRepository repository = FakeTaskRepository();
      final TaskEditorController createController = TaskEditorController(
        repository: repository,
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: RecordingTaskNotificationService(),
      );

      createController.updateTitle('Написать заметку');
      createController.updateDescription('Собрать материалы и сделать драфт');
      createController.updatePriority(TaskPriority.high);
      createController.updateCategory(TaskCategory.publication);

      final Task? created = await createController.save();

      expect(created, isNotNull);
      expect((await repository.getAllTasks()), hasLength(1));

      final TaskEditorController updateController = TaskEditorController(
        repository: repository,
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: RecordingTaskNotificationService(),
        initialTask: created,
      );
      updateController.updateTitle('Написать заметку и отправить редактору');

      final Task? updated = await updateController.save();

      expect(updated, isNotNull);
      expect(
        (await repository.getAllTasks()).single.title,
        'Написать заметку и отправить редактору',
      );
    },
  );
}

class RecordingTaskNotificationService extends AppNotificationService {
  RecordingTaskNotificationService() : super(logger: AppLogger());

  final List<({String title, String message})> errorEvents =
      <({String title, String message})>[];

  @override
  void show(NotificationConfig config) {}

  @override
  void showError({
    required String title,
    String? message,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    errorEvents.add((title: title, message: message ?? ''));
  }
}
