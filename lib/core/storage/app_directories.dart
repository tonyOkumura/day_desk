import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract final class AppDirectories {
  static Future<String> resolveDatabasePath() async {
    final Directory directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return directory.path;
  }
}
