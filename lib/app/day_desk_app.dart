import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get/get.dart';

import '../core/date/app_date_formatter.dart';
import 'controllers/theme_controller.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';
import 'theme/day_desk_scroll_behavior.dart';

class DayDeskApp extends StatelessWidget {
  const DayDeskApp({this.initialRoute, super.key});

  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Day Desk',
        debugShowCheckedModeBanner: false,
        locale: AppDateFormatter.appLocale,
        supportedLocales: const <Locale>[AppDateFormatter.appLocale],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        scrollBehavior: const DayDeskScrollBehavior(),
        themeMode: themeController.themeMode,
        theme: AppTheme.light(palette: themeController.palette),
        darkTheme: AppTheme.dark(palette: themeController.palette),
        initialRoute: initialRoute ?? AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
