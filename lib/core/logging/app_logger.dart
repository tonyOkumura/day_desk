import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger()
      : _logger = Logger(
          filter: _AppLogFilter(),
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 8,
            lineLength: 100,
            colors: true,
            printEmojis: false,
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
        );

  final Logger _logger;

  void debug(
    String message, {
    String? tag,
    Object? context,
  }) {
    if (!_shouldLog) {
      return;
    }

    _logger.d(
      _composeMessage(
        message,
        tag: tag,
        context: context,
      ),
    );
  }

  void info(
    String message, {
    String? tag,
    Object? context,
  }) {
    if (!_shouldLog) {
      return;
    }

    _logger.i(
      _composeMessage(
        message,
        tag: tag,
        context: context,
      ),
    );
  }

  void warning(
    String message, {
    String? tag,
    Object? context,
  }) {
    if (!_shouldLog) {
      return;
    }

    _logger.w(
      _composeMessage(
        message,
        tag: tag,
        context: context,
      ),
    );
  }

  void error(
    String message, {
    String? tag,
    Object? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(
      _composeMessage(
        message,
        tag: tag,
        context: context,
      ),
      error: error,
      stackTrace: stackTrace,
    );
  }

  bool get _shouldLog => kDebugMode || kProfileMode;

  String _composeMessage(
    String message, {
    String? tag,
    Object? context,
  }) {
    final StringBuffer buffer = StringBuffer('Day Desk');

    if (tag != null && tag.isNotEmpty) {
      buffer.write(' [$tag]');
    }

    buffer.write(': $message');

    if (context != null) {
      buffer.write(' | context=$context');
    }

    return buffer.toString();
  }
}

class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (event.level == Level.error || event.level == Level.fatal) {
      return true;
    }

    if (!(kDebugMode || kProfileMode)) {
      return false;
    }

    return event.level >= level!;
  }
}
