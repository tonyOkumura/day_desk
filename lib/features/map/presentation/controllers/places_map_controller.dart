import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:get/get.dart';

import '../../../../core/config/app_map_config.dart';
import '../../../../core/logging/app_logger.dart';

class PlacesMapController extends GetxController {
  PlacesMapController({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;
  final RxBool _tileLayerUnavailable = false.obs;
  late final fm.MapController mapController = fm.MapController();

  bool get tileLayerUnavailable => _tileLayerUnavailable.value;

  String get seedLocationLabel => AppMapConfig.seedLocationLabel;

  void recenterToMoscow() {
    mapController.move(
      AppMapConfig.moscowCenter,
      AppMapConfig.initialZoom,
      id: 'recenter-to-moscow',
    );
  }

  void handleTileLayerError(
    Object error, {
    StackTrace? stackTrace,
    String? details,
  }) {
    if (_tileLayerUnavailable.value) {
      return;
    }

    _tileLayerUnavailable.value = true;
    _logger.warning(
      'Подложка карты временно недоступна.',
      tag: 'map',
      context: details ?? error.toString(),
    );
    if (stackTrace != null) {
      _logger.debug(
        'Tile layer error stack trace captured.',
        tag: 'map',
        context: stackTrace.toString(),
      );
    }
  }
}
