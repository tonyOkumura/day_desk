import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/controllers/theme_controller.dart';
import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/page_content_frame.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/app_theme_palette.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../controllers/settings_controller.dart';

class SettingsContentPage extends GetView<SettingsController> {
  const SettingsContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final AppDateFormatter formatter = Get.find<AppDateFormatter>();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime now = DateTime.now();

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
                  'Рабочий день',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Эти значения станут базой для будущих расчётов свободных '
                  'окон и дневного ритма.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                Obx(
                  () => Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.lg,
                    children: <Widget>[
                      _SettingsDropdownField(
                        fieldKey: const Key('work-day-start-dropdown'),
                        label: 'Начало дня',
                        value: controller.workDayStartHour,
                        items: controller.availableStartHourOptions
                            .map(
                              (int hour) => DropdownMenuItem<int>(
                                value: hour,
                                child: Text(
                                  formatter.formatHourOfDay(hour),
                                  key: Key('work-day-start-option-$hour'),
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (int? hour) {
                          if (hour == null) {
                            return;
                          }

                          controller.setWorkDayStartHour(hour);
                        },
                      ),
                      _SettingsDropdownField(
                        fieldKey: const Key('work-day-end-dropdown'),
                        label: 'Конец дня',
                        value: controller.workDayEndHour,
                        items: controller.availableEndHourOptions
                            .map(
                              (int hour) => DropdownMenuItem<int>(
                                value: hour,
                                child: Text(
                                  formatter.formatHourOfDay(hour),
                                  key: Key('work-day-end-option-$hour'),
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (int? hour) {
                          if (hour == null) {
                            return;
                          }

                          controller.setWorkDayEndHour(hour);
                        },
                      ),
                    ],
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
                  'Свободные окна и напоминания',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Foundation-настройки уже можно подготовить заранее, даже '
                  'до появления задач, событий и системных reminder-ов.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _SettingsDropdownField(
                        fieldKey: const Key('minimum-free-slot-dropdown'),
                        label: 'Минимальное свободное окно',
                        value: controller.minimumFreeSlotMinutes,
                        items: SettingsController.freeSlotDurationOptions
                            .map(
                              (int minutes) => DropdownMenuItem<int>(
                                value: minutes,
                                child: Text(
                                  '$minutes мин',
                                  key: Key('minimum-free-slot-option-$minutes'),
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (int? minutes) {
                          if (minutes == null) {
                            return;
                          }

                          controller.setMinimumFreeSlotMinutes(minutes);
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SwitchListTile.adaptive(
                        key: const Key('notifications-enabled-switch'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Напоминания включены',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Это preference для будущих локальных уведомлений. '
                          'Текущие in-app системные подсказки не отключаются.',
                          style: textTheme.bodyMedium,
                        ),
                        value: controller.notificationsEnabled,
                        onChanged: controller.setNotificationsEnabled,
                      ),
                    ],
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
                            isSelected: themeController.palette == palette,
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
                  'приложения, а palette-aware theme system и foundation для '
                  'дат, времени и локальных настроек уже подключены к main '
                  'layout и настройкам.',
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
                const SizedBox(height: AppSpacing.sm),
                Obx(
                  () => Text(
                    'work_day='
                    '${formatter.formatHourOfDay(controller.workDayStartHour)}'
                    '-${formatter.formatHourOfDay(controller.workDayEndHour)}',
                    style: AppTypography.mono(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Obx(
                  () => Text(
                    'minimum_free_slot='
                    '${controller.minimumFreeSlotMinutes}',
                    style: AppTypography.mono(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Obx(
                  () => Text(
                    'notifications_enabled='
                    '${controller.notificationsEnabled}',
                    style: AppTypography.mono(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Примеры форматирования',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  formatter.formatFullDate(now),
                  style: AppTypography.mono(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  formatter.formatTime(now),
                  style: AppTypography.mono(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  formatter.formatRelativeDay(
                    now.add(const Duration(days: 1)),
                    reference: now,
                  ),
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

class _SettingsDropdownField extends StatelessWidget {
  const _SettingsDropdownField({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final Key fieldKey;
  final String label;
  final int value;
  final List<DropdownMenuItem<int>> items;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      child: KeyedSubtree(
        key: fieldKey,
        child: DropdownButtonFormField<int>(
          key: ValueKey<String>('${label}_$value'),
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(labelText: label),
          items: items,
          onChanged: onChanged,
        ),
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
