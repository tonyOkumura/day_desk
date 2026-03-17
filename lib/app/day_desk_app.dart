import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/theme_controller.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

class DayDeskApp extends StatelessWidget {
  const DayDeskApp({
    this.initialRoute,
    super.key,
  });

  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Day Desk',
        debugShowCheckedModeBanner: false,
        themeMode: themeController.themeMode,
        theme: AppTheme.light(palette: themeController.palette),
        darkTheme: AppTheme.dark(palette: themeController.palette),
        initialRoute: initialRoute ?? AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
