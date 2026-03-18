import 'package:day_desk/core/date/app_date_formatter.dart';
import 'package:day_desk/core/logging/app_logger.dart';
import 'package:day_desk/core/notifications/app_notification_service.dart';
import 'package:day_desk/core/notifications/notification_config.dart';
import 'package:day_desk/features/tasks/domain/entities/task.dart';
import 'package:day_desk/features/tasks/domain/entities/task_category.dart';
import 'package:day_desk/features/tasks/domain/entities/task_priority.dart';
import 'package:day_desk/features/tasks/domain/entities/task_status.dart';
import 'package:day_desk/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:day_desk/features/tasks/presentation/models/task_list_options.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../test_helpers/app_test_harness.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting(AppDateFormatter.localeName);
  });

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() async {
    Get.reset();
  });

  test(
    'TasksController по умолчанию показывает задачи на текущую дату',
    () async {
      final DateTime today = DateTime.now();
      final FakeTaskRepository repository = FakeTaskRepository(
        initialTasks: <Task>[
          _task(
            id: 'today',
            title: 'Задача на сегодня',
            date: DateTime(today.year, today.month, today.day),
          ),
          _task(
            id: 'tomorrow',
            title: 'Задача на завтра',
            date: DateTime(today.year, today.month, today.day + 1),
          ),
        ],
      );
      final TasksController controller = TasksController(
        repository: repository,
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: RecordingTaskNotificationService(),
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      expect(controller.listMode, TaskListMode.forDay);
      expect(controller.visibleTasks, hasLength(1));
      expect(controller.visibleTasks.single.id, 'today');
    },
  );

  test('TasksController переключается на Все и меняет сортировку', () async {
    final FakeTaskRepository repository = FakeTaskRepository(
      initialTasks: <Task>[
        _task(
          id: 'low',
          title: 'Низкий приоритет',
          date: DateTime(2026, 3, 18),
          priority: TaskPriority.low,
        ),
        _task(
          id: 'high',
          title: 'Высокий приоритет',
          date: DateTime(2026, 3, 19),
          priority: TaskPriority.high,
        ),
      ],
    );
    final TasksController controller = TasksController(
      repository: repository,
      dateFormatter: AppDateFormatter(),
      logger: AppLogger(),
      notificationService: RecordingTaskNotificationService(),
    );

    await controller.selectListMode(TaskListMode.allTasks);

    expect(controller.visibleTasks, hasLength(2));
    expect(controller.visibleTasks.first.id, 'low');

    controller.selectSortOption(TaskSortOption.priorityFirst);
    expect(controller.visibleTasks.first.id, 'high');
  });

  test(
    'TasksController переводит экран в error state при ошибке загрузки',
    () async {
      final TasksController controller = TasksController(
        repository: FakeTaskRepository(failOnLoad: true),
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: RecordingTaskNotificationService(),
      );

      await controller.retryLoading();

      expect(controller.hasError, isTrue);
      expect(controller.errorMessage, 'Не удалось загрузить задачи.');
    },
  );
}

Task _task({
  required String id,
  required String title,
  required DateTime date,
  TaskPriority priority = TaskPriority.medium,
}) {
  return Task(
    id: id,
    title: title,
    date: date,
    priority: priority,
    status: TaskStatus.pending,
    category: TaskCategory.work,
    createdAt: date,
    updatedAt: date,
  );
}

class RecordingTaskNotificationService extends AppNotificationService {
  RecordingTaskNotificationService() : super(logger: AppLogger());

  @override
  void show(NotificationConfig config) {}

  @override
  void showError({
    required String title,
    String? message,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {}
}
