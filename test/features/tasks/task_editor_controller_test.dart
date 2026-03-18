import 'package:day_desk/core/date/app_date_formatter.dart';
import 'package:day_desk/core/logging/app_logger.dart';
import 'package:day_desk/core/notifications/app_notification_service.dart';
import 'package:day_desk/core/notifications/notification_config.dart';
import 'package:day_desk/core/reminders/reminder_lead_time_preset.dart';
import 'package:day_desk/features/tasks/domain/entities/task.dart';
import 'package:day_desk/features/tasks/domain/entities/task_category.dart';
import 'package:day_desk/features/tasks/domain/entities/task_quadrant.dart';
import 'package:day_desk/features/tasks/domain/entities/task_status.dart';
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
    'TaskEditorController стартует с default reminder preset и разрешает его после дедлайна',
    () {
      final TaskEditorController controller = TaskEditorController(
        repository: FakeTaskRepository(),
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: RecordingTaskNotificationService(),
        defaultReminderPreset: ReminderLeadTimePreset.hour1,
      );

      expect(controller.reminderPreset, ReminderLeadTimePreset.hour1);
      expect(controller.resolvedReminderAt, isNull);
      expect(
        controller.reminderHelperText,
        'Напоминание активируется, когда появится дедлайн или точное время.',
      );

      controller.updateDeadline(DateTime(2026, 3, 18, 18));

      expect(controller.resolvedReminderAt, DateTime(2026, 3, 18, 17));
      expect(controller.reminderHelperText, 'Сработает 18 марта 2026, 17:00');
    },
  );

  test(
    'TaskEditorController сохраняет create и update через один flow с квадрантом и подпунктами',
    () async {
      final FakeTaskRepository repository = FakeTaskRepository();
      final TaskEditorController createController = TaskEditorController(
        repository: repository,
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: RecordingTaskNotificationService(),
      );

      createController.updateTitle('Сходить в магазин');
      createController.updateQuadrant(TaskQuadrant.quickWins);
      createController.updateCategory(TaskCategory.personal);
      createController.updateDeadline(DateTime(2026, 3, 18, 18));
      createController.updateReminderPreset(ReminderLeadTimePreset.hour1);
      createController.addSubtask();
      createController.updateSubtaskTitle(
        createController.subtasks.first.id,
        'Купить молоко',
      );

      final Task? created = await createController.save();

      expect(created, isNotNull);
      expect((await repository.getAllTasks()), hasLength(1));
      expect(created!.deadline, DateTime(2026, 3, 18, 18));
      expect(created.reminderPreset, ReminderLeadTimePreset.hour1);
      expect(created.reminderAt, DateTime(2026, 3, 18, 17));
      expect(created.status, TaskStatus.pending);
      expect(created.quadrant, TaskQuadrant.quickWins);
      expect(created.subtasks.single.title, 'Купить молоко');

      final TaskEditorController updateController = TaskEditorController(
        repository: repository,
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: RecordingTaskNotificationService(),
        initialTask: created,
      );
      updateController.updateTitle('Сходить в магазин и аптеку');

      final Task? updated = await updateController.save();

      expect(updated, isNotNull);
      expect(
        (await repository.getAllTasks()).single.title,
        'Сходить в магазин и аптеку',
      );
    },
  );

  test(
    'TaskEditorController сохраняет completion state при редактировании',
    () async {
      final FakeTaskRepository repository = FakeTaskRepository(
        initialTasks: <Task>[
          Task(
            id: 'completed-task',
            title: 'Готовая задача',
            date: DateTime(2026, 3, 18),
            status: TaskStatus.completed,
            createdAt: DateTime(2026, 3, 18, 10),
            updatedAt: DateTime(2026, 3, 18, 10),
          ),
        ],
      );

      final TaskEditorController controller = TaskEditorController(
        repository: repository,
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: RecordingTaskNotificationService(),
        initialTask: (await repository.getAllTasks()).single,
      );

      controller.updateTitle('Готовая задача обновлена');
      final Task? updated = await controller.save();

      expect(updated, isNotNull);
      expect(updated!.status, TaskStatus.completed);
    },
  );

  test(
    'TaskEditorController сохраняет preset без anchor с null reminderAt',
    () async {
      final FakeTaskRepository repository = FakeTaskRepository();
      final TaskEditorController controller = TaskEditorController(
        repository: repository,
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: RecordingTaskNotificationService(),
        defaultReminderPreset: ReminderLeadTimePreset.minutes15,
      );

      controller.updateTitle('Разобрать заметки');
      controller.setAllDay(false);

      final Task? created = await controller.save();

      expect(created, isNotNull);
      expect(created!.reminderPreset, ReminderLeadTimePreset.minutes15);
      expect(created.reminderAt, isNull);
      expect(created.quadrant, TaskQuadrant.schedule);
    },
  );

  test('TaskEditorController reorder-ит подпункты', () {
    final TaskEditorController controller = TaskEditorController(
      repository: FakeTaskRepository(),
      dateFormatter: AppDateFormatter(),
      logger: AppLogger(),
      notificationService: RecordingTaskNotificationService(),
    );

    controller.addSubtask();
    controller.addSubtask();
    controller.updateSubtaskTitle(controller.subtasks[0].id, 'Первое');
    controller.updateSubtaskTitle(controller.subtasks[1].id, 'Второе');

    controller.reorderSubtasks(0, 2);

    expect(controller.subtasks.map((item) => item.title).toList(), <String>[
      'Второе',
      'Первое',
    ]);
  });
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
