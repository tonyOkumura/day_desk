import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../features/settings/domain/entities/app_theme_preference.dart';
import '../controllers/theme_controller.dart';

class ThemeModeMenuButton extends StatelessWidget {
  const ThemeModeMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => PopupMenuButton<AppThemePreference>(
        tooltip: 'Режим темы',
        initialValue: themeController.preference,
        onSelected: themeController.setPreference,
        itemBuilder: (BuildContext context) {
          return AppThemePreference.values
              .map(
                (AppThemePreference preference) => PopupMenuItem<AppThemePreference>(
                  value: preference,
                  child: Row(
                    children: <Widget>[
                      Icon(preference.icon, size: 18),
                      const SizedBox(width: 12),
                      Text(preference.label),
                    ],
                  ),
                ),
              )
              .toList(growable: false);
        },
        icon: Icon(
          themeController.preference.icon,
        ),
      ),
    );
  }
}
