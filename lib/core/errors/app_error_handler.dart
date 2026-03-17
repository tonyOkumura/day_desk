import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';

abstract final class AppErrorHandler {
  static void install(AppLogger logger) {
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.error(
        'Flutter framework error.',
        tag: 'AppErrorHandler',
        error: details.exception,
        stackTrace: details.stack,
      );

      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (
      Object error,
      StackTrace stackTrace,
    ) {
      logger.error(
        'Platform dispatcher error.',
        tag: 'AppErrorHandler',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    };
  }
}
