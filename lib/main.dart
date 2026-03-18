import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'app/bootstrap/app_bootstrap.dart';
import 'core/logging/app_logger.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      final WidgetsBinding widgetsBinding =
          WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      await AppBootstrap.run();
    },
    (Object error, StackTrace stackTrace) {
      final AppLogger logger = Get.isRegistered<AppLogger>()
          ? Get.find<AppLogger>()
          : AppLogger();
      logger.error(
        'Unhandled zoned exception.',
        tag: 'main',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
