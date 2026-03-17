import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  void info(String message, {Object? details}) {
    if (!_shouldLog) {
      return;
    }

    developer.log(
      message,
      name: 'DayDesk',
      error: details,
    );
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'DayDesk',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  bool get _shouldLog => kDebugMode || kProfileMode;
}
