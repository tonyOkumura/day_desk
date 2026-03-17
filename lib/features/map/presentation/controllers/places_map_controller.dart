import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:get/get.dart';

import '../../../../core/config/app_map_config.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/map/map_tile_provider.dart';

class PlacesMapController extends GetxController {
  PlacesMapController({
    required AppLogger logger,
    required MapTileProvider tileProvider,
  }) : _logger = logger,
       _tileProvider = tileProvider;

  static const double compactSheetMinSize = 0.14;
  static const double compactSheetPeekSize = 0.18;
  static const double compactSheetExpandedSize = 0.64;

  final AppLogger _logger;
  final MapTileProvider _tileProvider;
  final RxBool _mapLoading = true.obs;
  final RxBool _tileLayerUnavailable = false.obs;
  final RxBool _desktopPanelOpen = true.obs;
  final RxBool _compactSheetExpanded = false.obs;
  final RxDouble _compactSheetExtent = compactSheetPeekSize.obs;
  final RxInt _tileLayerGeneration = 0.obs;
  late final fm.MapController mapController = fm.MapController();
  late final DraggableScrollableController sheetController =
      DraggableScrollableController();

  bool get isMapLoading => _mapLoading.value;
  bool get tileLayerUnavailable => _tileLayerUnavailable.value;
  bool get isDesktopPanelOpen => _desktopPanelOpen.value;
  bool get isCompactSheetExpanded => _compactSheetExpanded.value;
  double get compactSheetExtent => _compactSheetExtent.value;
  int get tileLayerGeneration => _tileLayerGeneration.value;
  double get compactSheetInitialSize =>
      isCompactSheetExpanded ? compactSheetExpandedSize : compactSheetPeekSize;

  String get seedLocationLabel => AppMapConfig.seedLocationLabel;
  MapTileSourceConfig get activeTileProvider => _tileProvider.sourceConfig;

  void recenterToMoscow() {
    mapController.move(
      AppMapConfig.moscowCenter,
      AppMapConfig.initialZoom,
      id: 'recenter-to-moscow',
    );
  }

  void togglePanel({required bool isCompactLayout}) {
    if (isCompactLayout) {
      if (isCompactSheetExpanded) {
        closePanel(isCompactLayout: true);
      } else {
        openPanel(isCompactLayout: true);
      }
      return;
    }

    _desktopPanelOpen.toggle();
  }

  void openPanel({required bool isCompactLayout}) {
    if (isCompactLayout) {
      _compactSheetExpanded.value = true;
      _compactSheetExtent.value = compactSheetExpandedSize;
      _animateSheetTo(compactSheetExpandedSize);
      return;
    }

    _desktopPanelOpen.value = true;
  }

  void closePanel({required bool isCompactLayout}) {
    if (isCompactLayout) {
      _compactSheetExpanded.value = false;
      _compactSheetExtent.value = compactSheetPeekSize;
      _animateSheetTo(compactSheetPeekSize);
      return;
    }

    _desktopPanelOpen.value = false;
  }

  void handleFirstTileRendered() {
    if (!_mapLoading.value) {
      return;
    }

    _mapLoading.value = false;
    _tileLayerUnavailable.value = false;
  }

  bool dismissOverlays({required bool isCompactLayout}) {
    if (isCompactLayout && isCompactSheetExpanded) {
      closePanel(isCompactLayout: true);
      return true;
    }

    if (!isCompactLayout && isDesktopPanelOpen) {
      closePanel(isCompactLayout: false);
      return true;
    }

    return false;
  }

  void updateCompactSheetExtent(double extent) {
    _compactSheetExtent.value = extent;
    _compactSheetExpanded.value =
        extent > (compactSheetPeekSize + compactSheetExpandedSize) / 2;
  }

  void retryLoading() {
    _tileLayerUnavailable.value = false;
    _mapLoading.value = true;
    _tileLayerGeneration.value++;
    _logger.info(
      'Retrying tile layer load.',
      tag: 'map',
      context: <String, Object?>{
        'provider': activeTileProvider.providerId,
        'cachePolicy': activeTileProvider.cachePolicy.name,
        'generation': _tileLayerGeneration.value,
      },
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
    _mapLoading.value = false;
    _logger.warning(
      'Подложка карты временно недоступна.',
      tag: 'map',
      context: <String, Object?>{
        'provider': activeTileProvider.providerId,
        'details': details ?? error.toString(),
      },
    );
    if (stackTrace != null) {
      _logger.debug(
        'Tile layer error stack trace captured.',
        tag: 'map',
        context: stackTrace.toString(),
      );
    }
  }

  void _animateSheetTo(double extent) {
    if (!sheetController.isAttached) {
      return;
    }

    unawaited(
      sheetController.animateTo(
        extent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void onClose() {
    sheetController.dispose();
    super.onClose();
  }
}
