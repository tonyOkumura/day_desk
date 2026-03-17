import 'package:day_desk/app/bindings/app_binding.dart';
import 'package:day_desk/app/bootstrap/app_startup_state.dart';
import 'package:day_desk/app/day_desk_app.dart';
import 'package:day_desk/core/logging/app_logger.dart';
import 'package:day_desk/core/notifications/app_notification_service.dart';
import 'package:day_desk/core/notifications/notification_config.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_palette.dart';
import 'package:day_desk/features/settings/domain/entities/app_theme_preference.dart';
import 'package:day_desk/features/settings/domain/repositories/app_settings_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class AppTestHarness {
  AppTestHarness._(this.repository);

  final FakeAppSettingsRepository repository;

  static Future<AppTestHarness> bootstrap({
    FakeAppSettingsRepository? repository,
  }) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;

    final FakeAppSettingsRepository resolvedRepository =
        repository ?? FakeAppSettingsRepository();

    if (!Get.isRegistered<AppLogger>()) {
      Get.put<AppLogger>(AppLogger(), permanent: true);
    }

    if (!Get.isRegistered<AppNotificationService>()) {
      Get.put<AppNotificationService>(
        FakeAppNotificationService(),
        permanent: true,
      );
    }

    Get.put<AppSettingsRepository>(resolvedRepository, permanent: true);
    Get.put<AppStartupState>(
      AppStartupState(
        initialThemePreference:
            await resolvedRepository.readThemePreference(),
        initialThemePalette:
            await resolvedRepository.readThemePalette(),
      ),
      permanent: true,
    );

    AppBinding().dependencies();

    return AppTestHarness._(resolvedRepository);
  }

  static void setSurfaceSize(
    WidgetTester tester, {
    required Size size,
  }) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
  }

  static void resetSurfaceSize(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await pumpAppWithRoute(tester);
  }

  Future<void> pumpAppWithRoute(
    WidgetTester tester, {
    String? initialRoute,
  }) async {
    await tester.pumpWidget(DayDeskApp(initialRoute: initialRoute));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> dispose() async {
    Get.reset();
  }
}

class FakeAppNotificationService extends AppNotificationService {
  FakeAppNotificationService()
      : super(
          logger: AppLogger(),
        );

  final List<({String title, String message})> successEvents =
      <({String title, String message})>[];
  final List<({String title, String message})> errorEvents =
      <({String title, String message})>[];

  @override
  void show(NotificationConfig config) {
    switch (config.type) {
      case NotificationType.success:
        successEvents.add((
          title: config.title,
          message: config.message ?? '',
        ));
      case NotificationType.error:
        errorEvents.add((
          title: config.title,
          message: config.message ?? '',
        ));
    }
  }

  @override
  void showSuccess({
    required String title,
    String? message,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    successEvents.add((title: title, message: message ?? ''));
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

class FakeAppSettingsRepository implements AppSettingsRepository {
  FakeAppSettingsRepository({
    AppThemePreference initialPreference = AppThemePreference.dark,
    AppThemePalette initialPalette = AppThemePalette.blue,
  })  : _preference = initialPreference,
        _palette = initialPalette;

  AppThemePreference _preference;
  AppThemePalette _palette;

  @override
  Future<AppThemePreference> readThemePreference() async {
    return _preference;
  }

  @override
  Future<AppThemePalette> readThemePalette() async {
    return _palette;
  }

  @override
  Future<void> saveThemePreference(AppThemePreference preference) async {
    _preference = preference;
  }

  @override
  Future<void> saveThemePalette(AppThemePalette palette) async {
    _palette = palette;
  }
}
