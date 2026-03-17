import 'package:flutter/material.dart';

import '../../features/settings/domain/entities/app_theme_palette.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_theme_schemes.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light({
    required AppThemePalette palette,
  }) {
    return _buildTheme(
      colorScheme: AppThemeSchemes.light(palette),
      brightness: Brightness.light,
    );
  }

  static ThemeData dark({
    required AppThemePalette palette,
  }) {
    return _buildTheme(
      colorScheme: AppThemeSchemes.dark(palette),
      brightness: Brightness.dark,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final TextTheme textTheme = AppTypography.theme(brightness).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    final Color elevatedSurface = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLow;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.96),
        elevation: 0,
        height: 72,
        indicatorColor: colorScheme.primary.withValues(
          alpha: isDark ? 0.22 : 0.14,
        ),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: elevatedSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    );
  }

  static Color surfaceColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return theme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.92)
        : colorScheme.surfaceContainerLow.withValues(alpha: 0.94);
  }
}
