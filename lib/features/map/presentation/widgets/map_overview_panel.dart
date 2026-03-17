import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/config/app_map_config.dart';
import '../controllers/places_map_controller.dart';

class MapOverviewPanel extends GetView<PlacesMapController> {
  const MapOverviewPanel({required this.isCompact, super.key});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Карта дня',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Сейчас это стартовый картографический scaffold: карта открывается '
          'на Москве, а позже сюда подключатся реальные места из событий, '
          'а затем и из задач.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            _MapChip(
              label: 'Стартовая область: ${AppMapConfig.seedLocationLabel}',
              icon: Icons.place_outlined,
            ),
            _MapChip(
              label: 'Данные позже придут из событий',
              icon: Icons.event_outlined,
            ),
            _MapChip(
              label: 'Затем добавятся задачи с местом',
              icon: Icons.checklist_rtl_outlined,
            ),
            _MapChip(
              label: 'Подложка: ${controller.activeTileProvider.providerLabel}',
              icon: Icons.layers_outlined,
            ),
            _MapChip(
              label:
                  'Режим tiles: ${controller.activeTileProvider.cachePolicy.label}',
              icon: Icons.cloud_sync_outlined,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Что уже заложено',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.md),
        ...const <String>[
          'Отдельная top-level вкладка карты внутри основного shell.',
          'Единый фундамент для будущих маркеров и camera actions.',
          'Маршрут /map и место в общей навигации уже закреплены.',
        ].map(
          (String item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(item, style: textTheme.bodyMedium)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Text(
            isCompact
                ? 'На телефоне карта остаётся главным canvas, а подробности '
                      'живут в выдвижном bottom sheet.'
                : 'На широких экранах детали живут в плавающей панели поверх '
                      'карты, чтобы не отнимать у неё ширину.',
            style: AppTypography.mono(
              context,
            ).copyWith(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
