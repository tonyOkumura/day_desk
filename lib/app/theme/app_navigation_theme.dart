import 'package:flutter/material.dart';

import 'package:sidebarx/sidebarx.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';

abstract final class AppNavigationTheme {
  static SidebarXTheme sidebar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SidebarXTheme(
      width: 84,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.94),
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 22,
      ),
      selectedIconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 22,
      ),
      textStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      selectedTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
      itemPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      selectedItemPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      itemMargin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      selectedItemMargin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      selectedItemDecoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      hoverColor: colorScheme.primary.withValues(alpha: 0.08),
      hoverTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      hoverIconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 22,
      ),
    );
  }

  static SidebarXTheme sidebarExtended(BuildContext context) {
    return sidebar(context).copyWith(
      width: 272,
      itemTextPadding: const EdgeInsets.only(left: AppSpacing.md),
      selectedItemTextPadding: const EdgeInsets.only(left: AppSpacing.md),
    );
  }

  static Color gNavBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surface.withValues(alpha: 0.96);
  }

  static Color gNavActiveColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color gNavInactiveColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color gNavTabBackground(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.14);
  }

  static List<BoxShadow> gNavShadow(BuildContext context) {
    return <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 18,
        offset: const Offset(0, -4),
      ),
    ];
  }

  static Gradient desktopBackground(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return LinearGradient(
      colors: isDark
          ? const <Color>[
              AppColors.graphite,
              AppColors.nearBlack,
            ]
          : const <Color>[
              AppColors.lightBackground,
              AppColors.lightPanel,
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
