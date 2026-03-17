import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/controllers/theme_controller.dart';
import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/page_content_frame.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/app_theme_palette.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../controllers/settings_controller.dart';

class SettingsContentPage extends GetView<SettingsController> {
  const SettingsContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return PageContentFrame(
      storageKey: AppDestination.settings.pageStorageKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Режим темы',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Выбери, как приложение должно использовать светлую и '
                  'тёмную версию активной палитры.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                Obx(
                  () => Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.lg,
                    children: controller.preferences
                        .map(
                          (AppThemePreference preference) => _ThemeCard(
                            preference: preference,
                            isSelected:
                                themeController.preference == preference,
                            onTap: () => controller.selectTheme(preference),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Палитра',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Material 3 палитра меняет характер интерфейса, а режим темы '
                  'по-прежнему выбирается отдельно.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                Obx(
                  () => Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.lg,
                    children: controller.palettes
                        .map(
                          (AppThemePalette palette) => _PaletteCard(
                            palette: palette,
                            isSelected:
                                themeController.palette == palette,
                            onTap: () => controller.selectPalette(palette),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Фундамент уже готов',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Локальное хранилище на Isar уже инициализируется при старте '
                  'приложения, а palette-aware theme system уже подключён к '
                  'main layout и настройкам.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'active_theme=${themeController.preference.name}',
                  style: AppTypography.mono(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'active_palette=${themeController.palette.name}',
                  style: AppTypography.mono(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.preference,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemePreference preference;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 1.6 : 1,
            ),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surface.withValues(alpha: 0.45),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(preference.icon),
              const SizedBox(height: AppSpacing.lg),
              Text(
                preference.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                preference.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  const _PaletteCard({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemePalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 1.6 : 1,
            ),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surface.withValues(alpha: 0.45),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: palette.previewColors
                    .map(
                      (Color color) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                palette.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                palette.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
