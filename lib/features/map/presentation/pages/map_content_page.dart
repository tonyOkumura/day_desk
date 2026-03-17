import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:get/get.dart';

import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/config/app_breakpoints.dart';
import '../../../../core/config/app_map_config.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../controllers/places_map_controller.dart';
import '../widgets/map_overview_panel.dart';

class MapContentPage extends GetView<PlacesMapController> {
  const MapContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useCompactLayout =
            constraints.maxWidth < AppBreakpoints.compactNavigation;
        final double edgePadding = useCompactLayout
            ? AppSpacing.md
            : AppSpacing.lg;
        final double desktopPanelWidth = math.min(
          420,
          math.max(360, constraints.maxWidth * 0.32),
        );

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const Positioned.fill(child: _MapSurface()),
            const Positioned.fill(child: _MapStatusOverlay()),
            Positioned(
              top: edgePadding,
              right: edgePadding,
              child: _MapActionCluster(
                compact: useCompactLayout,
                controller: controller,
              ),
            ),
            if (useCompactLayout)
              Positioned.fill(
                child: _CompactMapSheet(
                  controller: controller,
                  edgePadding: edgePadding,
                ),
              )
            else
              Positioned(
                top: edgePadding,
                left: edgePadding,
                bottom: edgePadding,
                width: desktopPanelWidth,
                child: _DesktopMapPanel(controller: controller),
              ),
            if (useCompactLayout)
              Obx(() {
                final double bottomOffset =
                    (constraints.maxHeight * controller.compactSheetExtent) +
                    edgePadding;

                return AnimatedPositioned(
                  key: const Key('map-seed-chip-position'),
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  left: edgePadding,
                  bottom: bottomOffset,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth - (edgePadding * 2),
                    ),
                    child: const _MapSeedChip(),
                  ),
                );
              })
            else
              Positioned(
                left: edgePadding,
                bottom: edgePadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth - (edgePadding * 2),
                  ),
                  child: const _MapSeedChip(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MapActionCluster extends StatelessWidget {
  const _MapActionCluster({required this.compact, required this.controller});

  final bool compact;
  final PlacesMapController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool panelOpen = compact
          ? controller.isCompactSheetExpanded
          : controller.isDesktopPanelOpen;

      return Column(
        key: const Key('map-action-cluster'),
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _MapIconControl(
            key: const Key('map-panel-toggle-button'),
            tooltip: panelOpen
                ? (compact ? 'Свернуть панель' : 'Скрыть панель')
                : (compact ? 'Раскрыть панель' : 'Показать панель'),
            onPressed: () {
              controller.togglePanel(isCompactLayout: compact);
            },
            icon: compact
                ? (panelOpen
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded)
                : (panelOpen
                      ? Icons.keyboard_double_arrow_left_rounded
                      : Icons.keyboard_double_arrow_right_rounded),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MapIconControl(
            key: const Key('map-recenter-button'),
            tooltip: 'Вернуться к Москве',
            icon: Icons.my_location_rounded,
            onPressed: controller.recenterToMoscow,
          ),
        ],
      );
    });
  }
}

class _DesktopMapPanel extends StatelessWidget {
  const _DesktopMapPanel({required this.controller});

  final PlacesMapController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: controller.isDesktopPanelOpen
            ? _MapOverlaySurface(
                key: const Key('map-desktop-panel'),
                child: SingleChildScrollView(
                  primary: false,
                  child: const MapOverviewPanel(isCompact: false),
                ),
              )
            : Align(
                alignment: Alignment.topLeft,
                child: _MapOverlaySurface(
                  padding: EdgeInsets.zero,
                  child: TextButton.icon(
                    key: const Key('map-panel-collapsed-button'),
                    onPressed: () {
                      controller.openPanel(isCompactLayout: false);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    icon: const Icon(Icons.info_outline_rounded),
                    label: const Text('Открыть детали'),
                  ),
                ),
              ),
      ),
    );
  }
}

class _CompactMapSheet extends StatelessWidget {
  const _CompactMapSheet({required this.controller, required this.edgePadding});

  final PlacesMapController controller;
  final double edgePadding;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (DraggableScrollableNotification notification) {
        controller.updateCompactSheetExtent(notification.extent);
        return false;
      },
      child: DraggableScrollableSheet(
        key: const Key('map-compact-sheet'),
        controller: controller.sheetController,
        initialChildSize: controller.compactSheetInitialSize,
        minChildSize: PlacesMapController.compactSheetMinSize,
        maxChildSize: PlacesMapController.compactSheetExpandedSize,
        snap: true,
        snapSizes: const <double>[
          PlacesMapController.compactSheetPeekSize,
          PlacesMapController.compactSheetExpandedSize,
        ],
        builder: (BuildContext context, ScrollController scrollController) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              edgePadding,
              0,
              edgePadding,
              edgePadding,
            ),
            child: _MapOverlaySurface(
              child: SingleChildScrollView(
                controller: scrollController,
                primary: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Карта дня',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Obx(
                          () => IconButton(
                            key: const Key('map-compact-sheet-toggle'),
                            tooltip: controller.isCompactSheetExpanded
                                ? 'Свернуть панель'
                                : 'Раскрыть панель',
                            onPressed: () {
                              controller.togglePanel(isCompactLayout: true);
                            },
                            icon: Icon(
                              controller.isCompactSheetExpanded
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_up_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const MapOverviewPanel(isCompact: true),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapSurface extends GetView<PlacesMapController> {
  const _MapSurface();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Obx(() {
      final int tileLayerGeneration = controller.tileLayerGeneration;
      final source = controller.activeTileProvider;

      return ClipRect(
        child: ColoredBox(
          key: const Key('map-interactive-surface'),
          color: colorScheme.surfaceContainerLowest,
          child: SizedBox.expand(
            child: fm.FlutterMap(
              key: const Key('moscow-map'),
              mapController: controller.mapController,
              options: const fm.MapOptions(
                initialCenter: AppMapConfig.moscowCenter,
                initialZoom: AppMapConfig.initialZoom,
                interactionOptions: fm.InteractionOptions(
                  flags: fm.InteractiveFlag.all & ~fm.InteractiveFlag.rotate,
                ),
              ),
              children: <Widget>[
                fm.TileLayer(
                  key: ValueKey<int>(tileLayerGeneration),
                  urlTemplate: source.urlTemplate,
                  userAgentPackageName: source.userAgentPackageName,
                  tileDisplay: const fm.TileDisplay.fadeIn(),
                  tileBuilder:
                      (
                        BuildContext context,
                        Widget tileWidget,
                        fm.TileImage tile,
                      ) {
                        if (tile.imageInfo != null && !tile.loadError) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.handleFirstTileRendered();
                          });
                        }
                        return tileWidget;
                      },
                  errorTileCallback:
                      (
                        fm.TileImage tile,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        controller.handleTileLayerError(
                          error,
                          stackTrace: stackTrace,
                          details: tile.coordinates.toString(),
                        );
                      },
                ),
                fm.RichAttributionWidget(
                  attributions: <fm.SourceAttribution>[
                    fm.TextSourceAttribution(source.attributionLabel),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _MapStatusOverlay extends GetView<PlacesMapController> {
  const _MapStatusOverlay();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.tileLayerUnavailable) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: _MapOverlaySurface(
              key: const Key('map-status-error'),
              child: AppErrorState(
                title: 'Не удалось загрузить карту',
                message:
                    'Подложка сейчас недоступна. Можно повторить загрузку или '
                    'продолжить работу с панелью карты.',
                actionLabel: 'Повторить',
                onAction: controller.retryLoading,
              ),
            ),
          ),
        );
      }

      if (controller.isMapLoading) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: _MapOverlaySurface(
              key: const Key('map-status-loading'),
              child: const AppLoadingState(
                title: 'Загружаем карту',
                message: 'Подключаем tiles и готовим интерактивный canvas.',
              ),
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }
}

class _MapSeedChip extends StatelessWidget {
  const _MapSeedChip();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return _MapOverlaySurface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        key: const Key('map-seed-chip'),
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.place_rounded, size: 18, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              'Стартовая область: ${AppMapConfig.seedLocationLabel}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapIconControl extends StatelessWidget {
  const _MapIconControl({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return _MapOverlaySurface(
      padding: EdgeInsets.zero,
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 500),
        child: SizedBox.square(
          dimension: 48,
          child: IconButton(onPressed: onPressed, icon: Icon(icon)),
        ),
      ),
    );
  }
}

class _MapOverlaySurface extends StatelessWidget {
  const _MapOverlaySurface({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.18 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
