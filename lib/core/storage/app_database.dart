import 'package:isar/isar.dart';

import '../logging/app_logger.dart';

class AppDatabase {
  AppDatabase({
    required AppLogger logger,
  }) : _logger = logger;

  final AppLogger _logger;
  Isar? _isar;

  Isar get isar {
    final Isar? instance = _isar;
    if (instance == null) {
      throw StateError('AppDatabase has not been opened yet.');
    }

    return instance;
  }

  Future<void> open({
    required List<CollectionSchema<dynamic>> schemas,
    required String directoryPath,
    required String name,
  }) async {
    if (_isar != null) {
      return;
    }

    _logger.info(
      'Opening local database.',
      details: directoryPath,
    );

    _isar = await Isar.open(
      schemas,
      directory: directoryPath,
      name: name,
      inspector: false,
    );
  }

  Future<void> close() async {
    final Isar? instance = _isar;
    if (instance == null) {
      return;
    }

    _logger.info('Closing local database.');
    await instance.close();
    _isar = null;
  }
}
