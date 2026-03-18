import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import '../../core/app_info/app_info_service.dart';
import '../../core/date/app_date_formatter.dart';
import '../../core/errors/app_error_handler.dart';
import '../../core/logging/app_logger.dart';
import '../../core/map/map_tile_provider.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/app_directories.dart';
import '../../features/settings/data/datasources/app_settings_local_data_source.dart';
import '../../features/settings/data/models/app_settings_local_model.dart';
import '../../features/settings/data/repositories/app_settings_repository_impl.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/repositories/app_settings_repository.dart';
import '../../features/tasks/data/datasources/task_local_data_source.dart';
import '../../features/tasks/data/models/task_local_model.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../bindings/app_binding.dart';
import '../day_desk_app.dart';
import 'app_launch_branding.dart';
import 'app_startup_state.dart';

class AppBootstrap {
  AppBootstrap._();

  static Future<void> run() async {
    Intl.defaultLocale = AppDateFormatter.localeName;
    await initializeDateFormatting(AppDateFormatter.localeName);

    final AppLogger logger = Get.isRegistered<AppLogger>()
        ? Get.find<AppLogger>()
        : Get.put<AppLogger>(AppLogger(), permanent: true);
    AppErrorHandler.install(logger);

    try {
      await initializeDependencies();
      runApp(const DayDeskApp());
    } catch (error, stackTrace) {
      logger.error(
        'Bootstrap failed before app startup.',
        tag: 'AppBootstrap',
        error: error,
        stackTrace: stackTrace,
      );
      runApp(
        BootstrapFailureApp(
          message:
              'Не удалось запустить Day Desk. Проверьте настройки '
              'окружения и повторите запуск.',
        ),
      );
    }
  }

  static Future<void> initializeDependencies({
    String? databaseDirectoryPath,
  }) async {
    if (Get.isRegistered<AppDatabase>()) {
      return;
    }

    final AppLogger logger = Get.isRegistered<AppLogger>()
        ? Get.find<AppLogger>()
        : Get.put<AppLogger>(AppLogger(), permanent: true);
    final String resolvedDirectoryPath =
        databaseDirectoryPath ?? await AppDirectories.resolveDatabasePath();

    final AppDatabase database = AppDatabase(logger: logger);
    await database.open(
      schemas: <CollectionSchema<dynamic>>[
        AppSettingsLocalModelSchema,
        TaskLocalModelSchema,
      ],
      directoryPath: resolvedDirectoryPath,
      name: 'day_desk',
    );
    Get.put<AppDatabase>(database, permanent: true);

    final AppSettingsLocalDataSource localDataSource =
        AppSettingsLocalDataSource(database.isar);
    final AppSettingsRepository settingsRepository = AppSettingsRepositoryImpl(
      localDataSource,
    );
    Get.put<AppSettingsRepository>(settingsRepository, permanent: true);

    final TaskLocalDataSource taskLocalDataSource = TaskLocalDataSource(
      database.isar,
    );
    final TaskRepository taskRepository = TaskRepositoryImpl(
      taskLocalDataSource,
    );
    Get.put<TaskRepository>(taskRepository, permanent: true);

    final AppSettings initialSettings = await settingsRepository.readSettings();
    final AppInfoService appInfoService = await AppInfoService.load(
      logger: logger,
    );
    Get.put<AppInfoService>(appInfoService, permanent: true);
    Get.put<MapTileProvider>(
      const OpenStreetMapTileProvider(),
      permanent: true,
    );

    final AppStartupState startupState = AppStartupState(
      initialSettings: initialSettings,
    );
    Get.put<AppStartupState>(startupState, permanent: true);

    AppBinding().dependencies();
  }

  static Future<void> resetDependencies() async {
    if (Get.isRegistered<AppDatabase>()) {
      await Get.find<AppDatabase>().close();
    }

    Get.reset();
  }
}

class BootstrapFailureApp extends StatefulWidget {
  const BootstrapFailureApp({required this.message, super.key});

  final String message;

  @override
  State<BootstrapFailureApp> createState() => _BootstrapFailureAppState();
}

class _BootstrapFailureAppState extends State<BootstrapFailureApp> {
  @override
  void initState() {
    super.initState();
    AppLaunchBranding.scheduleCloseAfterFirstFrame();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                widget.message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
