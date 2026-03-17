import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/theme_controller.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

class DayDeskApp extends StatelessWidget {
  const DayDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Day Desk',
        debugShowCheckedModeBanner: false,
        themeMode: themeController.themeMode,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
