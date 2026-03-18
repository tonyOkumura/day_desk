import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../app/controllers/theme_controller.dart';
import '../../../../app/navigation/app_destination.dart';
import '../../../../app/shell/page_content_frame.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/app_info/app_info_service.dart';
import '../../../../core/date/app_date_formatter.dart';
import '../../../../core/reminders/reminder_lead_time_preset.dart';
import '../../../../core/widgets/adaptive_section_grid.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../domain/entities/app_theme_palette.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../controllers/settings_controller.dart';

class SettingsContentPage extends GetView<SettingsController> {
  const SettingsContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final AppInfoService appInfoService = Get.find<AppInfoService>();
    final AppDateFormatter formatter = Get.find<AppDateFormatter>();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime now = DateTime.now();

    return PageContentFrame(
      storageKey: AppDestination.settings.pageStorageKey,
      child: AdaptiveSectionGrid(
        children: <Widget>[
          AppSectionCard(
            title: 'Режим темы',
            description:
                'Выбери, как приложение должно использовать светлую и тёмную '
                'версию активной палитры.',
            child: Obx(
              () => Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: controller.preferences
                    .map(
                      (AppThemePreference preference) => _ThemeCard(
                        preference: preference,
                        isSelected: themeController.preference == preference,
                        onTap: () => controller.selectTheme(preference),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          AppSectionCard(
            title: 'Рабочий день',
            description:
                'Эти значения станут базой для будущих расчётов свободных окон '
                'и дневного ритма.',
            child: Obx(
              () => Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: <Widget>[
                  AppDropdownField<int>(
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
                      if (hour != null) {
                        controller.setWorkDayStartHour(hour);
                      }
                    },
                  ),
                  AppDropdownField<int>(
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
                      if (hour != null) {
                        controller.setWorkDayEndHour(hour);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          AppSectionCard(
            title: 'Свободные окна и напоминания',
            description:
                'Foundation-настройки уже можно подготовить заранее, даже до '
                'появления задач, событий и системных reminder-ов.',
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppDropdownField<int>(
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
                      if (minutes != null) {
                        controller.setMinimumFreeSlotMinutes(minutes);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppDropdownField<ReminderLeadTimePreset>(
                    fieldKey: const Key('default-reminder-preset-dropdown'),
                    label: 'Напоминание по умолчанию',
                    value: controller.defaultReminderPreset,
                    items: SettingsController.reminderPresetOptions
                        .map(
                          (
                            ReminderLeadTimePreset preset,
                          ) => DropdownMenuItem<ReminderLeadTimePreset>(
                            value: preset,
                            child: Text(
                              preset.label,
                              key: Key(
                                'default-reminder-preset-option-${preset.name}',
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (ReminderLeadTimePreset? preset) {
                      if (preset != null) {
                        controller.setDefaultReminderPreset(preset);
                      }
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
          ),
          AppSectionCard(
            title: 'Палитра',
            description:
                'Material 3 палитра меняет характер интерфейса, а режим темы '
                'по-прежнему выбирается отдельно.',
            child: Obx(
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
          ),
          AppSectionCard(
            key: const Key('about-section'),
            title: 'О приложении',
            description:
                'Системная информация о текущей сборке и базовом runtime '
                'приложения.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _InfoRow(label: 'Название', value: appInfoService.info.appName),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(label: 'Версия', value: appInfoService.info.version),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(
                  label: 'Build',
                  value: appInfoService.info.buildNumber,
                ),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(
                  label: 'Package',
                  value: appInfoService.info.packageName,
                  useMono: true,
                ),
              ],
            ),
          ),
          AppSectionCard(
            key: const Key('reset-settings-section'),
            title: 'Сброс настроек',
            description:
                'Сбрасываются только foundation-настройки: тема, палитра, '
                'рабочий день, свободные окна и preference напоминаний. '
                'Будущие данные задач и событий это действие не затронет.',
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                key: const Key('reset-settings-button'),
                label: 'Сбросить настройки',
                icon: Icons.restart_alt_rounded,
                variant: AppButtonVariant.danger,
                onPressed: () async {
                  final bool confirmed = await AppConfirmDialog.show(
                    context,
                    title: 'Сбросить настройки?',
                    message:
                        'Текущие foundation-настройки вернутся к значениям '
                        'по умолчанию. Это действие не затрагивает будущие '
                        'данные задач и событий.',
                    confirmLabel: 'Сбросить',
                    isDestructive: true,
                  );

                  if (confirmed) {
                    await controller.resetSettings();
                  }
                },
              ),
            ),
          ),
          AppSectionCard(
            title: 'Фундамент уже готов',
            description:
                'Локальное хранилище на Isar, palette-aware theme system и '
                'foundation для даты, времени и настроек уже подключены к '
                'основному shell приложения.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                    'default_reminder='
                    '${controller.defaultReminderPreset.name}',
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.useMono = false,
  });

  final String label;
  final String value;
  final bool useMono;

  @override
  Widget build(BuildContext context) {
    final TextStyle? valueStyle = useMono
        ? AppTypography.mono(context)
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(value, style: valueStyle)),
      ],
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
