import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:native_splash_screen/native_splash_screen.dart' as nss;

class AppLaunchBranding {
  AppLaunchBranding._();

  static bool _closeScheduled = false;
  static bool _closed = false;

  static void scheduleCloseAfterFirstFrame() {
    if (_closeScheduled) {
      return;
    }

    _closeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      close();
    });
  }

  static void close() {
    if (_closed) {
      return;
    }

    _closed = true;

    try {
      FlutterNativeSplash.remove();
    } catch (_) {
      // Ignore missing plugin/runtime integration during tests and unsupported hosts.
    }

    if (kIsWeb) {
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        try {
          nss.close(animation: nss.CloseAnimation.fade);
        } catch (_) {
          // Ignore missing plugin/runtime integration during tests and unsupported hosts.
        }
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        break;
    }
  }
}
