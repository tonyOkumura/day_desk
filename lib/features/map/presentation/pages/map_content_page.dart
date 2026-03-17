import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:get/get.dart';

import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/config/app_breakpoints.dart';
import '../../../../core/config/app_map_config.dart';
import '../../../../core/widgets/app_surface_card.dart';
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
        final bool useCompactDensity =
            constraints.maxWidth < AppBreakpoints.compactDensity;
        final double horizontalPadding = useCompactDensity
            ? AppSpacing.lg
            : AppSpacing.xl;
        final double bottomPadding = useCompactDensity
            ? AppSpacing.lg
            : AppSpacing.xl;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            bottomPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.pageMaxWidth,
              ),
              child: useCompactLayout
                  ? Column(
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 220),
                          child: _MapPanelViewport(isCompact: true),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: _MapSurface(
                            compact: true,
                            controller: controller,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        const SizedBox(
                          width: 344,
                          child: _MapPanelViewport(isCompact: false),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: _MapSurface(
                            compact: false,
                            controller: controller,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _MapPanelViewport extends StatelessWidget {
  const _MapPanelViewport({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: MapOverviewPanel(isCompact: isCompact),
    );
  }
}

class _MapSurface extends StatelessWidget {
  const _MapSurface({required this.compact, required this.controller});

  final bool compact;
  final PlacesMapController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.16 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Container(
                key: const Key('map-interactive-surface'),
                color: colorScheme.surfaceContainerLowest,
                child: fm.FlutterMap(
                  key: const Key('moscow-map'),
                  mapController: controller.mapController,
                  options: const fm.MapOptions(
                    initialCenter: AppMapConfig.moscowCenter,
                    initialZoom: AppMapConfig.initialZoom,
                    interactionOptions: fm.InteractionOptions(
                      flags:
                          fm.InteractiveFlag.all & ~fm.InteractiveFlag.rotate,
                    ),
                  ),
                  children: <Widget>[
                    fm.TileLayer(
                      urlTemplate: AppMapConfig.tileUrlTemplate,
                      userAgentPackageName: AppMapConfig.userAgentPackageName,
                      tileDisplay: const fm.TileDisplay.fadeIn(),
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
                    const fm.RichAttributionWidget(
                      attributions: <fm.SourceAttribution>[
                        fm.TextSourceAttribution(AppMapConfig.attributionLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.lg,
              right: AppSpacing.lg,
              child: Tooltip(
                message: 'Вернуться к Москве',
                waitDuration: const Duration(milliseconds: 500),
                child: FilledButton.tonal(
                  key: const Key('map-recenter-button'),
                  onPressed: controller.recenterToMoscow,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    minimumSize: Size(compact ? 44 : 48, compact ? 44 : 48),
                    backgroundColor: colorScheme.surface.withValues(
                      alpha: 0.92,
                    ),
                    foregroundColor: colorScheme.onSurface,
                  ),
                  child: const Icon(Icons.my_location_rounded),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: AppSurfaceCard(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.place_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Стартовая область: ${AppMapConfig.seedLocationLabel}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (!controller.tileLayerUnavailable) {
                return const SizedBox.shrink();
              }

              return Positioned(
                left: AppSpacing.lg,
                top: AppSpacing.lg,
                child: Container(
                  key: const Key('map-tile-error-chip'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.26),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 16,
                        color: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Подложка карты временно недоступна',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
