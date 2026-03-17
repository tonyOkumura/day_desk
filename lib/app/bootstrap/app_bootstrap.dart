import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../../core/errors/app_error_handler.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/app_database.dart';
import '../../core/storage/app_directories.dart';
import '../../features/settings/data/datasources/app_settings_local_data_source.dart';
import '../../features/settings/data/models/app_settings_local_model.dart';
import '../../features/settings/data/repositories/app_settings_repository_impl.dart';
import '../../features/settings/domain/repositories/app_settings_repository.dart';
import '../bindings/app_binding.dart';
import '../day_desk_app.dart';
import 'app_startup_state.dart';

class AppBootstrap {
  AppBootstrap._();

  static Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    final AppLogger logger = AppLogger();
    Get.put<AppLogger>(logger, permanent: true);
    AppErrorHandler.install(logger);

    await runZonedGuarded(
      () async {
        try {
          await initializeDependencies();
          runApp(const DayDeskApp());
        } catch (error, stackTrace) {
          logger.error(
            'Bootstrap failed before app startup.',
            error: error,
            stackTrace: stackTrace,
          );
          runApp(
            BootstrapFailureApp(
              message: 'Не удалось запустить Day Desk. Проверьте настройки '
                  'окружения и повторите запуск.',
            ),
          );
        }
      },
      (Object error, StackTrace stackTrace) {
        logger.error(
          'Unhandled zoned exception.',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
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
      ],
      directoryPath: resolvedDirectoryPath,
      name: 'day_desk',
    );
    Get.put<AppDatabase>(database, permanent: true);

    final AppSettingsLocalDataSource localDataSource =
        AppSettingsLocalDataSource(database.isar);
    final AppSettingsRepository settingsRepository =
        AppSettingsRepositoryImpl(localDataSource);
    Get.put<AppSettingsRepository>(settingsRepository, permanent: true);

    final AppStartupState startupState = AppStartupState(
      initialThemePreference:
          await settingsRepository.readThemePreference(),
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

class BootstrapFailureApp extends StatelessWidget {
  const BootstrapFailureApp({
    required this.message,
    super.key,
  });

  final String message;

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
                message,
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
