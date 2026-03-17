import 'package:day_desk/app/controllers/main_layout_controller.dart';
import 'package:day_desk/app/controllers/theme_controller.dart';
import 'package:day_desk/app/navigation/app_destination.dart';
import 'package:day_desk/app/routes/app_routes.dart';
import 'package:day_desk/features/map/presentation/controllers/places_map_controller.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_palette.dart';
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
    expect(find.text('Карта дня'), findsOneWidget);
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
    expect(find.text('Модуль задач'), findsOneWidget);
  });

  testWidgets(
    'на широком экране карта показывает split view с панелью и картой',
    (WidgetTester tester) async {
      final AppTestHarness harness = await AppTestHarness.bootstrap();
      addTearDown(() async => harness.dispose());

      AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
      addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

      await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.map);

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('Карта дня'), findsOneWidget);
      expect(find.textContaining('Стартовая область: Москва'), findsWidgets);
      expect(find.byKey(const Key('map-recenter-button')), findsOneWidget);
    },
  );

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
      expect(find.text('Модуль задач'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(450, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.currentDestination, AppDestination.calendar);
      expect(controller.currentRoutePath, AppDestination.calendar.route);
      expect(find.text('Модуль календаря'), findsOneWidget);
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

    await tester.ensureVisible(
      find.byKey(const Key('work-day-start-dropdown')),
    );
    await tester.tap(find.byKey(const Key('work-day-start-dropdown')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('work-day-start-option-18')), findsNothing);

    await tester.tap(find.byKey(const Key('work-day-start-option-8')).last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('work-day-end-dropdown')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('work-day-end-option-8')), findsNothing);
  });

  testWidgets(
    'Ctrl+2 переключает на карту и переводит фокус на активную страницу',
    (WidgetTester tester) async {
      final AppTestHarness harness = await AppTestHarness.bootstrap();
      addTearDown(() async => harness.dispose());

      AppTestHarness.setSurfaceSize(tester, size: const Size(1440, 960));
      addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

      await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.today);

      final MainLayoutController controller = Get.find<MainLayoutController>();

      await _sendControlShortcut(tester, LogicalKeyboardKey.digit2);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final Focus mapFocus = tester.widget<Focus>(
        find.byKey(const Key('page-focus-map')),
      );

      expect(controller.currentDestination, AppDestination.map);
      expect(controller.currentRoutePath, AppDestination.map.route);
      expect(mapFocus.focusNode?.hasPrimaryFocus, isTrue);
    },
  );

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
    'ошибка tile layer показывает fallback chip без падения страницы',
    (WidgetTester tester) async {
      final AppTestHarness harness = await AppTestHarness.bootstrap();
      addTearDown(() async => harness.dispose());

      AppTestHarness.setSurfaceSize(tester, size: const Size(390, 844));
      addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

      await harness.pumpAppWithRoute(tester, initialRoute: AppRoutes.map);

      final PlacesMapController controller = Get.find<PlacesMapController>();
      controller.handleTileLayerError(Exception('tile test failure'));
      await tester.pump();

      expect(find.byKey(const Key('map-tile-error-chip')), findsOneWidget);
      expect(find.text('Подложка карты временно недоступна'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
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
