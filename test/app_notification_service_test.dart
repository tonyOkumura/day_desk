import 'package:day_desk/core/logging/app_logger.dart';
import 'package:day_desk/core/notifications/app_notification_service.dart';
import 'package:day_desk/core/notifications/notification_config.dart';
import 'package:day_desk/core/widgets/glass_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('overlay stack ограничен четырьмя уведомлениями', (
    WidgetTester tester,
  ) async {
    final RecordingAppLogger logger = RecordingAppLogger();
    final AppNotificationService service = AppNotificationService(
      logger: logger,
    );
    int overflowCloseCount = 0;

    await _pumpOverlayHost(tester, width: 1280);

    service.showSuccess(
      title: 'One',
      message: '1',
      onClose: () => overflowCloseCount++,
    );
    service.showSuccess(title: 'Two', message: '2');
    service.showSuccess(title: 'Three', message: '3');
    service.showSuccess(title: 'Four', message: '4');
    service.showSuccess(title: 'Five', message: '5');
    await tester.pump();

    expect(service.notificationCount, 4);
    expect(overflowCloseCount, 1);
    expect(find.byType(GlassNotification), findsNWidgets(4));
    expect(find.text('One'), findsNothing);
    expect(find.text('Five'), findsOneWidget);
  });

  testWidgets('на узком экране overlay выравнивается по topCenter', (
    WidgetTester tester,
  ) async {
    final AppNotificationService service = AppNotificationService(
      logger: RecordingAppLogger(),
    );

    await _pumpOverlayHost(tester, width: 390);

    service.showSuccess(title: 'Centered', message: 'Compact');
    await tester.pump();

    final Align overlayAlign = tester.widget<Align>(
      find.byKey(const Key('notification-overlay-align')),
    );
    expect(overlayAlign.alignment, Alignment.topCenter);
  });

  testWidgets('на широком экране overlay выравнивается по topRight', (
    WidgetTester tester,
  ) async {
    final AppNotificationService service = AppNotificationService(
      logger: RecordingAppLogger(),
    );

    await _pumpOverlayHost(tester, width: 1280);

    service.showSuccess(title: 'Right', message: 'Desktop');
    await tester.pump();

    final Align overlayAlign = tester.widget<Align>(
      find.byKey(const Key('notification-overlay-align')),
    );
    expect(overlayAlign.alignment, Alignment.topRight);
  });

  testWidgets('кнопка close снимает уведомление', (
    WidgetTester tester,
  ) async {
    final AppNotificationService service = AppNotificationService(
      logger: RecordingAppLogger(),
    );
    int onCloseCount = 0;

    await _pumpOverlayHost(tester, width: 1280);

    service.show(
      NotificationConfig.error(
        title: 'Closable',
        message: 'Dismiss me',
        duration: const Duration(minutes: 1),
        onClose: () => onCloseCount++,
      ),
    );
    await tester.pump();

    expect(find.text('Closable'), findsOneWidget);

    await tester.tap(find.byKey(const Key('notification-close-0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));

    expect(find.text('Closable'), findsNothing);
    expect(service.notificationCount, 0);
    expect(onCloseCount, 1);
  });

  testWidgets('tap по уведомлению вызывает onTap и закрывает карточку', (
    WidgetTester tester,
  ) async {
    final AppNotificationService service = AppNotificationService(
      logger: RecordingAppLogger(),
    );
    int tapCount = 0;

    await _pumpOverlayHost(tester, width: 1280);

    service.show(
      NotificationConfig.success(
        title: 'Tap me',
        message: 'Action',
        duration: const Duration(minutes: 1),
        onTap: () => tapCount++,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Tap me'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));

    expect(tapCount, 1);
    expect(find.text('Tap me'), findsNothing);
  });
}

Future<void> _pumpOverlayHost(
  WidgetTester tester, {
  required double width,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 844);

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    Get.reset();
  });

  await tester.pumpWidget(
    const GetMaterialApp(
      home: Scaffold(
        body: SizedBox.expand(),
      ),
    ),
  );
  await tester.pump();
}

class RecordingAppLogger extends AppLogger {
  final List<String> warningEvents = <String>[];
  final List<String> errorEvents = <String>[];

  @override
  void warning(
    String message, {
    String? tag,
    Object? context,
  }) {
    warningEvents.add(message);
  }

  @override
  void error(
    String message, {
    String? tag,
    Object? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    errorEvents.add(message);
  }
}
