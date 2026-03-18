import 'package:day_desk/app/controllers/main_layout_controller.dart';
import 'package:day_desk/app/controllers/theme_controller.dart';
import 'package:day_desk/app/navigation/app_destination.dart';
import 'package:day_desk/app/routes/app_routes.dart';
import 'package:day_desk/core/reminders/reminder_lead_time_preset.dart';
import 'package:day_desk/features/map/presentation/controllers/places_map_controller.dart';
import 'package:day_desk/features/settings/domain/entities/app_settings.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_palette.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_preference.dart';
import 'package:day_desk/features/settings/presentation/controllers/settings_controller.dart';
import 'package:day_desk/features/tasks/domain/entities/task.dart';
import 'package:day_desk/features/tasks/domain/entities/task_category.dart';
import 'package:day_desk/features/tasks/domain/entities/task_quadrant.dart';
import 'package:day_desk/features/tasks/domain/entities/task_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sidebarx/sidebarx.dart';

import 'test_helpers/app_test_harness.dart';

void main() {
  testWidgets('приложение стартует с экраном Сегодня', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.today);

    final MainLayoutController controller = Get.find<MainLayoutController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final BuildContext context = tester.element(find.text('Сегодня').first);

    expect(controller.currentDestination, AppDestination.today);
    expect(themeController.palette, AppThemePalette.blue);
    expect(Localizations.localeOf(context), const Locale('ru', 'RU'));
    expect(find.text('Сегодня'), findsWidgets);
    expect(find.byKey(const Key('page-app-bar-today')), findsOneWidget);
    expect(find.text('Главный экран дня'), findsOneWidget);
  });

  testWidgets('прямой запуск маршрута /map открывает вкладку карты', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.map);

    final MainLayoutController controller = Get.find<MainLayoutController>();

    expect(controller.currentDestination, AppDestination.map);
    expect(find.text('Карта'), findsWidgets);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Карта дня'), findsWidgets);
    expect(find.byKey(const Key('page-app-bar-map')), findsOneWidget);
    expect(find.byKey(const Key('map-compact-sheet')), findsOneWidget);
    expect(find.byKey(const Key('map-status-loading')), findsOneWidget);
    expect(
      find.text(
        'Стартовый картографический экран Москвы и будущих мест на день.',
      ),
      findsNothing,
    );
  });

  testWidgets('на узком экране используется google nav bar', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpApp(tester);

    expect(find.byType(GNav), findsOneWidget);
    expect(find.byType(SidebarX), findsNothing);
    expect(find.byKey(const Key('compact-nav-map')), findsOneWidget);
  });

  testWidgets('на широком экране используется sidebarx', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpApp(tester);

    expect(find.byType(SidebarX), findsOneWidget);
    expect(find.byType(GNav), findsNothing);
    expect(find.byKey(const Key('sidebarx_toggle_button')), findsOneWidget);
  });

  testWidgets('прямой запуск маршрута /tasks открывает ту же раскладку', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.tasks);

    final MainLayoutController controller = Get.find<MainLayoutController>();

    expect(controller.currentDestination, AppDestination.tasks);
    expect(find.text('Задачи'), findsWidgets);
    expect(find.byKey(const Key('page-app-bar-tasks')), findsOneWidget);
    expect(find.byKey(const Key('tasks-state-empty')), findsOneWidget);
    expect(find.text('Матрица пока пустая'), findsOneWidget);
    expect(find.byKey(const Key('tasks-add-button')), findsOneWidget);
    expect(find.byKey(const Key('tasks-filter-button')), findsOneWidget);
    expect(find.byKey(const Key('tasks-view-mode-matrix')), findsOneWidget);
  });

  testWidgets(
    'compact matrix с задачами рендерится без ошибок framework и storage crash',
    (WidgetTester tester) async {
      final DateTime today = DateTime.now();
      final AppTestHarness harness = await AppTestHarness.bootstrap(
        taskRepository: FakeTaskRepository(
          initialTasks: <Task>[
            Task(
              id: 'compact-task',
              title: 'Проверить compact matrix',
              date: DateTime(today.year, today.month, today.day),
              isUrgent: true,
              isImportant: true,
              status: TaskStatus.pending,
              category: TaskCategory.work,
              createdAt: today,
              updatedAt: today,
            ),
          ],
        ),
      );
      addTearDown(() async => harness.dispose());

      AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
      addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

      await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.tasks);

      expect(find.byKey(const Key('tasks-matrix-compact')), findsOneWidget);
      expect(find.text('Проверить compact matrix'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'на широком экране карта работает как immersive canvas с overlay panel',
    (WidgetTester tester) async {
      final AppTestHarness harness = await AppTestHarness.bootstrap();
      addTearDown(() async => harness.dispose());

      AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
      addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

      await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.map);

      final Size mapSize = tester.getSize(
        find.byKey(const Key('map-interactive-surface')),
      );

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byKey(const Key('map-desktop-panel')), findsOneWidget);
      expect(find.byKey(const Key('page-app-bar-map')), findsOneWidget);
      expect(find.byKey(const Key('map-recenter-button')), findsOneWidget);
      expect(mapSize.width, greaterThan(950));
      expect(mapSize.height, greaterThan(620));
    },
  );

  testWidgets('desktop panel на карте скрывается по toggle и по Escape', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.map);

    expect(find.byKey(const Key('map-desktop-panel')), findsOneWidget);

    await tester.tap(find.byKey(const Key('map-panel-toggle-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('map-desktop-panel')), findsNothing);
    expect(find.byKey(const Key('map-panel-collapsed-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('map-panel-collapsed-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('map-desktop-panel')), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('map-desktop-panel')), findsNothing);
    expect(find.byKey(const Key('map-panel-collapsed-button')), findsOneWidget);
  });

  testWidgets(
    'тап по нижней навигации и свайп синхронизируют текущую вкладку',
    (WidgetTester tester) async {
      final AppTestHarness harness = await AppTestHarness.bootstrap();
      addTearDown(() async => harness.dispose());

      AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
      addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

      await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.today);

      final MainLayoutController controller = Get.find<MainLayoutController>();

      await tester.tap(find.byIcon(Icons.checklist_rtl_outlined).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(controller.currentDestination, AppDestination.tasks);
      expect(controller.currentRoutePath, AppDestination.tasks.route);
      expect(find.byKey(const Key('tasks-state-empty')), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(450, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.currentDestination, AppDestination.calendar);
      expect(controller.currentRoutePath, AppDestination.calendar.route);
      expect(find.text('Модуль календаря'), findsOneWidget);
    },
  );

  testWidgets('на compact layout новая задача открывается fullscreen editor', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.tasks);

    await tester.ensureVisible(find.byKey(const Key('tasks-add-button')));
    await tester.tap(find.byKey(const Key('tasks-add-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('task-editor-fullscreen')), findsOneWidget);
    expect(find.byKey(const Key('task-editor-title-field')), findsOneWidget);
    expect(
      find.byKey(const Key('task-editor-quadrant-selector')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('task-editor-add-subtask-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('task-editor-deadline-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('task-editor-reminder-preset-dropdown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('task-editor-status-dropdown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('task-editor-reminder-preset-dropdown')),
      findsOneWidget,
    );
  });

  testWidgets('на wide layout редактирование задачи открывается dialog', (
    WidgetTester tester,
  ) async {
    final DateTime today = DateTime.now();
    final AppTestHarness harness = await AppTestHarness.bootstrap(
      taskRepository: FakeTaskRepository(
        initialTasks: <Task>[
          Task(
            id: 'task-1',
            title: 'Подготовить бриф',
            date: DateTime(today.year, today.month, today.day),
            isUrgent: TaskQuadrant.doNow.isUrgent,
            isImportant: TaskQuadrant.doNow.isImportant,
            status: TaskStatus.pending,
            category: TaskCategory.work,
            createdAt: today,
            updatedAt: today,
          ),
        ],
      ),
    );
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.tasks);

    expect(
      find.byKey(const Key('task-postpone-button-task-1')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('task-edit-button-task-1')),
    );
    await tester.tap(find.byKey(const Key('task-edit-button-task-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('task-editor-dialog')), findsOneWidget);
    expect(find.byKey(const Key('task-editor-title-field')), findsOneWidget);
    expect(
      find.byKey(const Key('task-editor-quadrant-selector')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('task-editor-deadline-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('task-editor-status-dropdown')),
      findsOneWidget,
    );
  });

  testWidgets('на wide layout задачу можно перетащить в другой квадрант', (
    WidgetTester tester,
  ) async {
    final DateTime today = DateTime.now();
    final FakeTaskRepository taskRepository = FakeTaskRepository(
      initialTasks: <Task>[
        Task(
          id: 'drag-task',
          title: 'Перетащить в срочное',
          date: DateTime(today.year, today.month, today.day),
          isUrgent: false,
          isImportant: true,
          status: TaskStatus.pending,
          category: TaskCategory.work,
          createdAt: today,
          updatedAt: today,
        ),
      ],
    );
    final AppTestHarness harness = await AppTestHarness.bootstrap(
      taskRepository: taskRepository,
    );
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.tasks);

    final Offset source = tester.getCenter(
      find.byKey(const Key('task-card-drag-task')),
    );
    final Offset target = tester.getCenter(
      find.byKey(const Key('task-matrix-group-doNow')),
    );

    final TestGesture gesture = await tester.startGesture(source);
    await tester.pump(const Duration(milliseconds: 180));
    await gesture.moveTo(target);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final Task updated = (await taskRepository.getAllTasks()).single;
    expect(updated.quadrant, TaskQuadrant.doNow);
  });

  testWidgets(
    'resize между sidebar и bottom nav не сбрасывает tasks viewport на экран Сегодня',
    (WidgetTester tester) async {
      final DateTime today = DateTime.now();
      final AppTestHarness harness = await AppTestHarness.bootstrap(
        taskRepository: FakeTaskRepository(
          initialTasks: <Task>[
            Task(
              id: 'resize-task',
              title: 'Остаться на экране задач',
              date: DateTime(today.year, today.month, today.day),
              isUrgent: false,
              isImportant: true,
              status: TaskStatus.pending,
              category: TaskCategory.work,
              createdAt: today,
              updatedAt: today,
            ),
          ],
        ),
      );
      addTearDown(() async => harness.dispose());

      AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
      addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

      await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.tasks);

      final MainLayoutController controller = Get.find<MainLayoutController>();

      expect(controller.currentDestination, AppDestination.tasks);
      expect(find.byKey(const Key('tasks-matrix-medium')), findsOneWidget);
      expect(find.text('Остаться на экране задач'), findsOneWidget);

      AppTestHarness.setSurfaceSize(tester, size: const Size(700, 900));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(GNav), findsOneWidget);
      expect(controller.currentDestination, AppDestination.tasks);
      expect(find.byKey(const Key('tasks-matrix-compact')), findsOneWidget);
      expect(find.text('Остаться на экране задач'), findsOneWidget);
      expect(find.text('Главный экран дня'), findsNothing);
      expect(tester.takeException(), isNull);

      AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(SidebarX), findsOneWidget);
      expect(controller.currentDestination, AppDestination.tasks);
      expect(find.byKey(const Key('tasks-matrix-medium')), findsOneWidget);
      expect(find.text('Остаться на экране задач'), findsOneWidget);
      expect(find.text('Главный экран дня'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'выбранные тема, палитра и foundation-настройки сохраняются между перезапусками',
    (WidgetTester tester) async {
      final FakeAppSettingsRepository repository = FakeAppSettingsRepository();

      final AppTestHarness firstHarness = await AppTestHarness.bootstrap(
        repository: repository,
      );

      AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
      addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

      await firstHarness.pumpAppWithRoute(
        tester,
        initialRoute: AppRoutes.settings,
      );

      final Finder lightThemeCard = find.widgetWithText(InkWell, 'Светлая');
      final Finder greenPaletteCard = find.widgetWithText(InkWell, 'Зелёная');
      await tester.ensureVisible(lightThemeCard);
      await tester.tap(lightThemeCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.ensureVisible(greenPaletteCard);
      await tester.tap(greenPaletteCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      await tester.ensureVisible(
        find.byKey(const Key('work-day-start-dropdown')),
      );
      await tester.tap(find.byKey(const Key('work-day-start-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('work-day-start-option-8')).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('work-day-end-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('work-day-end-option-19')).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('minimum-free-slot-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('minimum-free-slot-option-45')).last,
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('default-reminder-preset-dropdown')),
      );
      await tester.tap(
        find.byKey(const Key('default-reminder-preset-dropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('default-reminder-preset-option-day1')).last,
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('notifications-enabled-switch')),
      );
      await tester.tap(find.byKey(const Key('notifications-enabled-switch')));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await firstHarness.dispose();

      final AppTestHarness secondHarness = await AppTestHarness.bootstrap(
        repository: repository,
      );
      addTearDown(() async => secondHarness.dispose());

      await secondHarness.pumpAppWithRoute(
        tester,
        initialRoute: AppRoutes.settings,
      );

      expect(find.text('active_theme=light'), findsOneWidget);
      expect(find.text('active_palette=green'), findsOneWidget);
      expect(find.text('work_day=08:00-19:00'), findsOneWidget);
      expect(find.text('minimum_free_slot=45'), findsOneWidget);
      expect(find.text('default_reminder=day1'), findsOneWidget);
      expect(find.text('notifications_enabled=false'), findsOneWidget);
    },
  );

  testWidgets('dropdown options не позволяют выбрать невалидные границы дня', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.settings);
    final SettingsController controller = Get.find<SettingsController>();

    expect(controller.availableStartHourOptions.contains(18), isFalse);
    await tester.ensureVisible(
      find.byKey(const Key('work-day-start-dropdown')),
    );
    await tester.tap(find.byKey(const Key('work-day-start-dropdown')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('work-day-start-option-8')).last);
    await tester.pumpAndSettle();

    expect(controller.workDayStartHour, 8);
    expect(controller.availableEndHourOptions.contains(8), isFalse);
    await tester.tap(find.byKey(const Key('work-day-end-dropdown')));
    await tester.pumpAndSettle();
  });

  testWidgets('Ctrl+2 переключает на карту', (WidgetTester tester) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.today);

    final MainLayoutController controller = Get.find<MainLayoutController>();

    await _sendControlShortcut(tester, LogicalKeyboardKey.digit2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(controller.currentDestination, AppDestination.map);
    expect(controller.currentRoutePath, AppDestination.map.route);
  });

  testWidgets('Ctrl+B работает только в expanded layout', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.today);

    final MainLayoutController controller = Get.find<MainLayoutController>();

    expect(controller.sidebarController.extended, isTrue);
    await _sendControlShortcut(tester, LogicalKeyboardKey.keyB);
    await tester.pump();

    expect(controller.sidebarController.extended, isFalse);

    AppTestHarness.setSurfaceSize(tester, size: const Size(700, 900));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(GNav), findsOneWidget);
    await _sendControlShortcut(tester, LogicalKeyboardKey.keyB);
    await tester.pump();

    expect(controller.sidebarController.extended, isFalse);
  });

  testWidgets('Escape снимает фокус с page anchor без побочных эффектов', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.today);

    await _sendControlShortcut(tester, LogicalKeyboardKey.digit4);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final Finder tasksFocusFinder = find.byKey(const Key('page-focus-tasks'));
    final Focus focusedPage = tester.widget<Focus>(tasksFocusFinder);
    expect(focusedPage.focusNode?.hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    final Focus unfocusedPage = tester.widget<Focus>(tasksFocusFinder);
    expect(unfocusedPage.focusNode?.hasPrimaryFocus, isFalse);
  });

  testWidgets('узкие desktop-ширины не ломают shell и не дают overflow', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.today);

    for (final Size size in <Size>[
      const Size(1200, 900),
      const Size(900, 900),
      const Size(700, 900),
      const Size(560, 900),
    ]) {
      AppTestHarness.setSurfaceSize(tester, size: size);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Сегодня'), findsWidgets);
    }
  });

  testWidgets('drag по карте на compact layout не переключает PageView', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.map);

    final MainLayoutController controller = Get.find<MainLayoutController>();

    await tester.drag(
      find.byKey(const Key('map-interactive-surface')),
      const Offset(-220, 0),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(controller.currentDestination, AppDestination.map);
    expect(controller.currentRoutePath, AppDestination.map.route);
  });

  testWidgets(
    'ошибка tile layer показывает fallback state и retry возвращает loading',
    (WidgetTester tester) async {
      final AppTestHarness harness = await AppTestHarness.bootstrap();
      addTearDown(() async => harness.dispose());

      AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
      addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

      await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.map);

      final PlacesMapController controller = Get.find<PlacesMapController>();
      controller.handleTileLayerError(Exception('tile test failure'));
      await tester.pump();

      expect(find.byKey(const Key('map-status-error')), findsOneWidget);
      expect(find.text('Не удалось загрузить карту'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);

      await tester.tap(find.text('Повторить'));
      await tester.pump();

      expect(find.byKey(const Key('map-status-loading')), findsOneWidget);
    },
  );

  testWidgets('desktop-scroll content получает scrollbar', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.today);

    expect(find.byType(Scrollbar), findsWidgets);
  });

  testWidgets('settings показывают about section и reset action', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.settings);

    await tester.ensureVisible(find.byKey(const Key('about-section')));

    expect(find.text('О приложении'), findsOneWidget);
    expect(find.text('Day Desk'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(
      find.byKey(const Key('default-reminder-preset-dropdown')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reset-settings-button')), findsOneWidget);
  });

  testWidgets(
    'reset settings возвращает дефолтные значения через confirm dialog',
    (WidgetTester tester) async {
      final FakeAppSettingsRepository repository = FakeAppSettingsRepository(
        initialSettings: const AppSettings(
          themePreference: AppThemePreference.light,
          themePalette: AppThemePalette.green,
          workDayStartHour: 8,
          workDayEndHour: 19,
          minimumFreeSlotMinutes: 45,
          defaultReminderPreset: ReminderLeadTimePreset.day1,
          notificationsEnabled: false,
        ),
      );
      final AppTestHarness harness = await AppTestHarness.bootstrap(
        repository: repository,
      );
      addTearDown(() async => harness.dispose());

      AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
      addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

      await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.settings);
      await tester.ensureVisible(
        find.byKey(const Key('reset-settings-button')),
      );

      await tester.tap(find.byKey(const Key('reset-settings-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Сбросить'));
      await tester.pumpAndSettle();

      expect(find.text('active_theme=dark'), findsOneWidget);
      expect(find.text('active_palette=blue'), findsOneWidget);
      expect(find.text('work_day=09:00-18:00'), findsOneWidget);
      expect(find.text('minimum_free_slot=30'), findsOneWidget);
      expect(find.text('default_reminder=minutes15'), findsOneWidget);
      expect(find.text('notifications_enabled=true'), findsOneWidget);
    },
  );
}

Future<void> _sendControlShortcut(
  WidgetTester tester,
  LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
}
