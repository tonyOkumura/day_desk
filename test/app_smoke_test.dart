import 'package:day_desk/app/controllers/main_layout_controller.dart';
import 'package:day_desk/app/controllers/theme_controller.dart';
import 'package:day_desk/app/navigation/app_destination.dart';
import 'package:day_desk/app/routes/app_routes.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_palette.dart';
import 'package:flutter/material.dart';
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

    AppTestHarness.setSurfaceSize(
      tester,
      size: const Size(390, 844),
    );
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(
      tester,
      initialRoute: AppRoutes.today,
    );

    final MainLayoutController controller = Get.find<MainLayoutController>();
    final ThemeController themeController = Get.find<ThemeController>();

    expect(controller.currentDestination, AppDestination.today);
    expect(themeController.palette, AppThemePalette.blue);
    expect(find.text('Сегодня'), findsWidgets);
    expect(find.text('Главный экран дня'), findsOneWidget);
  });

  testWidgets('на узком экране используется google nav bar', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(
      tester,
      size: const Size(390, 844),
    );
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpApp(tester);

    expect(find.byType(GNav), findsOneWidget);
    expect(find.byType(SidebarX), findsNothing);
  });

  testWidgets('на широком экране используется sidebarx', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(
      tester,
      size: const Size(1440, 960),
    );
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

    AppTestHarness.setSurfaceSize(
      tester,
      size: const Size(390, 844),
    );
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(
      tester,
      initialRoute: AppRoutes.tasks,
    );

    final MainLayoutController controller = Get.find<MainLayoutController>();

    expect(controller.currentDestination, AppDestination.tasks);
    expect(find.text('Задачи'), findsWidgets);
    expect(find.text('Модуль задач'), findsOneWidget);
  });

  testWidgets('тап по нижней навигации и свайп синхронизируют текущую вкладку', (
    WidgetTester tester,
  ) async {
    final AppTestHarness harness = await AppTestHarness.bootstrap();
    addTearDown(() async => harness.dispose());

    AppTestHarness.setSurfaceSize(
      tester,
      size: const Size(390, 844),
    );
    addTearDown(() => AppTestHarness.resetSurfaceSize(tester));

    await harness.pumpAppWithRoute(
      tester,
      initialRoute: AppRoutes.today,
    );

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
  });

  testWidgets('выбранные тема и палитра сохраняются между перезапусками', (
    WidgetTester tester,
  ) async {
    final FakeAppSettingsRepository repository = FakeAppSettingsRepository();

    final AppTestHarness firstHarness =
        await AppTestHarness.bootstrap(repository: repository);

    AppTestHarness.setSurfaceSize(
      tester,
      size: const Size(390, 844),
    );
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

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await firstHarness.dispose();

    final AppTestHarness secondHarness =
        await AppTestHarness.bootstrap(repository: repository);
    addTearDown(() async => secondHarness.dispose());

    await secondHarness.pumpAppWithRoute(
      tester,
      initialRoute: AppRoutes.settings,
    );

    expect(find.text('active_theme=light'), findsOneWidget);
    expect(find.text('active_palette=green'), findsOneWidget);
  });
}
