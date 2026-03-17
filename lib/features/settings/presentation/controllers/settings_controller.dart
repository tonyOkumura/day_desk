import 'package:get/get.dart';

import '../../../../app/controllers/theme_controller.dart';
import '../../domain/entities/app_theme_palette.dart';
import '../../domain/entities/app_theme_preference.dart';

class SettingsController extends GetxController {
  final ThemeController _themeController = Get.find<ThemeController>();

  List<AppThemePreference> get preferences => AppThemePreference.values;
  List<AppThemePalette> get palettes => AppThemePalette.values;

  AppThemePreference get currentPreference => _themeController.preference;
  AppThemePalette get currentPalette => _themeController.palette;

  Future<void> selectTheme(AppThemePreference preference) {
    return _themeController.setPreference(preference);
  }

  Future<void> selectPalette(AppThemePalette palette) {
    return _themeController.setPalette(palette);
  }
}
