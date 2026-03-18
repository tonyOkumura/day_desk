import 'package:day_desk/core/date/app_date_formatter.dart';
import 'package:day_desk/core/logging/app_logger.dart';
import 'package:day_desk/core/notifications/app_notification_service.dart';
import 'package:day_desk/core/notifications/notification_config.dart';
import 'package:day_desk/features/tasks/domain/entities/task.dart';
import 'package:day_desk/features/tasks/domain/entities/task_category.dart';
import 'package:day_desk/features/tasks/domain/entities/task_checklist_item.dart';
import 'package:day_desk/features/tasks/domain/entities/task_quadrant.dart';
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
    'TasksController по умолчанию показывает матрицу задач на текущую дату',
    () async {
      final DateTime today = DateTime.now();
      final FakeTaskRepository repository = FakeTaskRepository(
        initialTasks: <Task>[
          _task(
            id: 'today',
            title: 'Задача на сегодня',
            date: DateTime(today.year, today.month, today.day),
            quadrant: TaskQuadrant.doNow,
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

      expect(controller.viewMode, TaskViewMode.matrix);
      expect(controller.scopeMode, TaskScopeMode.forDay);
      expect(controller.visibleTasks, hasLength(1));
      expect(controller.visibleTasks.single.id, 'today');
      expect(
        controller.matrixGroups
            .firstWhere((group) => group.quadrant == TaskQuadrant.doNow)
            .tasks
            .single
            .id,
        'today',
      );
    },
  );

  test('TasksController переключается на Все и меняет list sorting', () async {
    final FakeTaskRepository repository = FakeTaskRepository(
      initialTasks: <Task>[
        _task(
          id: 'later',
          title: 'Позже по сроку',
          date: DateTime(2026, 3, 18),
          deadline: DateTime(2026, 3, 20, 18),
        ),
        _task(
          id: 'soon',
          title: 'Скоро по сроку',
          date: DateTime(2026, 3, 19),
          deadline: DateTime(2026, 3, 19, 10),
        ),
      ],
    );
    final TasksController controller = TasksController(
      repository: repository,
      dateFormatter: AppDateFormatter(),
      logger: AppLogger(),
      notificationService: RecordingTaskNotificationService(),
    );

    await controller.selectScopeMode(TaskScopeMode.allTasks);
    controller.selectViewMode(TaskViewMode.list);

    expect(controller.visibleTasks, hasLength(2));
    expect(controller.visibleTasks.first.id, 'soon');

    controller.selectListSortOption(TaskListSortOption.recentlyUpdated);
    expect(controller.visibleTasks.first.id, 'soon');
  });

  test(
    'TasksController показывает все задачи и сортирует overdue -> open -> completed',
    () async {
      final FakeTaskRepository repository = FakeTaskRepository(
        nowProvider: () => DateTime(2026, 3, 20, 12),
        initialTasks: <Task>[
          _task(
            id: 'pending',
            title: 'Активная задача',
            date: DateTime(2026, 3, 21),
            quadrant: TaskQuadrant.schedule,
          ),
          _task(
            id: 'overdue',
            title: 'Просроченная задача',
            date: DateTime(2026, 3, 18),
            quadrant: TaskQuadrant.doNow,
            deadline: DateTime(2026, 3, 19, 18),
          ),
          _task(
            id: 'completed',
            title: 'Готовая задача',
            date: DateTime(2026, 3, 18),
            quadrant: TaskQuadrant.quickWins,
            status: TaskStatus.completed,
          ),
        ],
      );
      final TasksController controller = TasksController(
        repository: repository,
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: RecordingTaskNotificationService(),
      );

      await controller.selectScopeMode(TaskScopeMode.allTasks);

      expect(
        controller.visibleTasks.map((Task task) => task.id).toList(),
        <String>['overdue', 'pending', 'completed'],
      );
      expect(
        controller.matrixGroups
            .firstWhere((group) => group.quadrant == TaskQuadrant.doNow)
            .tasks
            .single
            .id,
        'overdue',
      );
    },
  );

  test(
    'TasksController ищет по title и подпунктам и умеет reclassify',
    () async {
      final FakeTaskRepository repository = FakeTaskRepository(
        initialTasks: <Task>[
          _task(
            id: 'task-1',
            title: 'Купить продукты',
            date: DateTime.now(),
            quadrant: TaskQuadrant.quickWins,
            subtasks: const <TaskChecklistItem>[
              TaskChecklistItem(id: 'sub-1', title: 'Молоко', sortOrder: 0),
            ],
          ),
          _task(
            id: 'task-2',
            title: 'Подготовить отчёт',
            date: DateTime.now(),
            quadrant: TaskQuadrant.schedule,
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

      controller.updateSearchQuery('молоко');
      expect(controller.visibleTasks.map((Task task) => task.id), <String>[
        'task-1',
      ]);

      final Task created = (await repository.getAllTasks()).first;
      await controller.reclassifyTask(created, TaskQuadrant.doNow);
      final Task reclassified = (await repository.getAllTasks()).first;
      expect(reclassified.quadrant, TaskQuadrant.doNow);
    },
  );

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

  test('TasksController переключает подпункт inline', () async {
    final Task task = _task(
      id: 'task-inline',
      title: 'Сходить в магазин',
      date: DateTime(2026, 3, 18),
      subtasks: const <TaskChecklistItem>[
        TaskChecklistItem(id: 'sub-1', title: 'Купить молоко', sortOrder: 0),
      ],
    );
    final FakeTaskRepository repository = FakeTaskRepository(
      initialTasks: <Task>[task],
    );
    final TasksController controller = TasksController(
      repository: repository,
      dateFormatter: AppDateFormatter(),
      logger: AppLogger(),
      notificationService: RecordingTaskNotificationService(),
    );

    await controller.toggleSubtaskCompletion(task, task.subtasks.single);

    final Task updated = (await repository.getAllTasks()).single;
    expect(updated.subtasks.single.isCompleted, isTrue);
  });

  test(
    'TasksController не завершает задачу с незакрытыми подпунктами и показывает info notification',
    () async {
      final Task task = _task(
        id: 'task-guard',
        title: 'Разобрать покупки',
        date: DateTime(2026, 3, 18),
        subtasks: const <TaskChecklistItem>[
          TaskChecklistItem(id: 'sub-1', title: 'Купить молоко', sortOrder: 0),
        ],
      );
      final FakeTaskRepository repository = FakeTaskRepository(
        initialTasks: <Task>[task],
      );
      final RecordingTaskNotificationService notifications =
          RecordingTaskNotificationService();
      final TasksController controller = TasksController(
        repository: repository,
        dateFormatter: AppDateFormatter(),
        logger: AppLogger(),
        notificationService: notifications,
      );

      await controller.toggleTaskCompletion(task);

      final Task unchanged = (await repository.getAllTasks()).single;
      expect(unchanged.status, TaskStatus.pending);
      expect(notifications.infoEvents, hasLength(1));
      expect(
        notifications.infoEvents.single.title,
        'Сначала заверши подпункты',
      );
    },
  );
}

Task _task({
  required String id,
  required String title,
  required DateTime date,
  TaskQuadrant quadrant = TaskQuadrant.schedule,
  TaskStatus status = TaskStatus.pending,
  DateTime? deadline,
  List<TaskChecklistItem> subtasks = const <TaskChecklistItem>[],
}) {
  return Task(
    id: id,
    title: title,
    date: date,
    deadline: deadline,
    isUrgent: quadrant.isUrgent,
    isImportant: quadrant.isImportant,
    subtasks: subtasks,
    status: status,
    category: TaskCategory.work,
    createdAt: date,
    updatedAt: date,
  );
}

class RecordingTaskNotificationService extends AppNotificationService {
  RecordingTaskNotificationService() : super(logger: AppLogger());

  final List<({String title, String message})> infoEvents =
      <({String title, String message})>[];
  final List<({String title, String message})> errorEvents =
      <({String title, String message})>[];

  @override
  void show(NotificationConfig config) {}

  @override
  void showInfo({
    required String title,
    String? message,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    infoEvents.add((title: title, message: message ?? ''));
  }

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
