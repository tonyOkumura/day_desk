import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

    await harness.pumpApp(tester);

    expect(find.text('Сегодня'), findsWidgets);
    expect(find.textContaining('Главный экран дня'), findsOneWidget);
  });

  testWidgets('на узком экране используется нижняя навигация', (
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

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('на широком экране используется rail navigation', (
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

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('выбранная тема сохраняется между перезапусками', (
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

    await firstHarness.pumpApp(tester);
    await tester.tap(find.byIcon(Icons.tune_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final Finder lightThemeCard = find.widgetWithText(InkWell, 'Светлая');
    await tester.ensureVisible(lightThemeCard);
    await tester.tap(lightThemeCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await firstHarness.dispose();

    final AppTestHarness secondHarness =
        await AppTestHarness.bootstrap(repository: repository);
    addTearDown(() async => secondHarness.dispose());

    await secondHarness.pumpApp(tester);
    if (find.text('active_theme=light').evaluate().isEmpty) {
      final Finder settingsIcon = find.byIcon(Icons.tune_outlined).evaluate().isNotEmpty
          ? find.byIcon(Icons.tune_outlined)
          : find.byIcon(Icons.tune_rounded);
      await tester.tap(settingsIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    expect(find.text('active_theme=light'), findsOneWidget);
  });
}
