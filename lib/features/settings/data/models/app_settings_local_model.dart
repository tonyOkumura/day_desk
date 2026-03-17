import 'package:isar/isar.dart';

import '../../domain/entities/app_theme_palette.dart';
import '../../domain/entities/app_theme_preference.dart';

part 'app_settings_local_model.g.dart';

@collection
class AppSettingsLocalModel {
  AppSettingsLocalModel();

  static const int singletonId = 0;

  Id id = singletonId;

  @Enumerated(EnumType.name)
  AppThemePreference themePreference = AppThemePreference.dark;

  @Enumerated(EnumType.name)
  AppThemePalette themePalette = AppThemePalette.blue;

  DateTime updatedAt = DateTime.now();
}
