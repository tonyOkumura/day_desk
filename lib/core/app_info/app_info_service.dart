import 'package:package_info_plus/package_info_plus.dart';

import '../logging/app_logger.dart';
import 'app_info.dart';

class AppInfoService {
  factory AppInfoService.fallback() {
    return const AppInfoService(
      AppInfo(
        appName: 'Day Desk',
        packageName: 'com.example.day_desk',
        version: '1.0.0',
        buildNumber: '1',
      ),
    );
  }

  const AppInfoService(this.info);

  final AppInfo info;

  static Future<AppInfoService> load({AppLogger? logger}) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return AppInfoService(
        AppInfo(
          appName: packageInfo.appName,
          packageName: packageInfo.packageName,
          version: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
        ),
      );
    } catch (error, stackTrace) {
      logger?.warning(
        'Falling back to default app metadata.',
        tag: 'AppInfoService',
        context: error.toString(),
      );
      logger?.debug(
        'App metadata load stack trace captured.',
        tag: 'AppInfoService',
        context: stackTrace.toString(),
      );
      return AppInfoService.fallback();
    }
  }
}
