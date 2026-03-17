import 'package:get/get.dart';

import '../../../../app/controllers/theme_controller.dart';
import '../../domain/entities/app_theme_preference.dart';

class SettingsController extends GetxController {
  final ThemeController _themeController = Get.find<ThemeController>();

  List<AppThemePreference> get preferences => AppThemePreference.values;

  AppThemePreference get currentPreference => _themeController.preference;

  Future<void> selectTheme(AppThemePreference preference) {
    return _themeController.setPreference(preference);
  }
}
