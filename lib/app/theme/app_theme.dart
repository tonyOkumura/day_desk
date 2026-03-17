import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.electricBlue,
      onPrimary: Colors.white,
      secondary: AppColors.electricBlueSoft,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      primaryContainer: const Color(0xFFDCE9FF),
      onPrimaryContainer: AppColors.lightText,
      secondaryContainer: const Color(0xFFE5F0FF),
      onSecondaryContainer: AppColors.lightText,
      tertiary: AppColors.warning,
      onTertiary: Colors.black,
      tertiaryContainer: const Color(0xFFFFF2D6),
      onTertiaryContainer: Colors.black,
      errorContainer: const Color(0xFFFFE2E0),
      onErrorContainer: const Color(0xFF5E1515),
      surfaceContainerHighest: AppColors.lightPanel,
      onSurfaceVariant: const Color(0xFF516072),
      outline: const Color(0xFFB8C3D4),
      outlineVariant: const Color(0xFFD5DEEA),
      shadow: Colors.black.withValues(alpha: 0.12),
      scrim: Colors.black.withValues(alpha: 0.45),
      inverseSurface: AppColors.nearBlack,
      onInverseSurface: AppColors.offWhite,
      inversePrimary: AppColors.electricBlueSoft,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: AppTypography.applySans(ThemeData.light().textTheme),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface.withValues(alpha: 0.94),
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.electricBlue.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.lightSurface.withValues(alpha: 0.88),
        selectedIconTheme: const IconThemeData(color: AppColors.electricBlue),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.electricBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
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
    );

    return base;
  }

  static ThemeData dark() {
    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.electricBlueSoft,
      onPrimary: Colors.black,
      secondary: AppColors.electricBlue,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.nearBlack,
      onSurface: AppColors.offWhite,
      primaryContainer: const Color(0xFF123162),
      onPrimaryContainer: AppColors.offWhite,
      secondaryContainer: const Color(0xFF162744),
      onSecondaryContainer: AppColors.offWhite,
      tertiary: AppColors.warning,
      onTertiary: Colors.black,
      tertiaryContainer: const Color(0xFF46300A),
      onTertiaryContainer: const Color(0xFFFFE5B2),
      errorContainer: const Color(0xFF4A1D1D),
      onErrorContainer: const Color(0xFFFFDAD5),
      surfaceContainerHighest: AppColors.panel,
      onSurfaceVariant: AppColors.muted,
      outline: const Color(0xFF3A4A62),
      outlineVariant: const Color(0xFF263247),
      shadow: Colors.black.withValues(alpha: 0.45),
      scrim: Colors.black.withValues(alpha: 0.75),
      inverseSurface: AppColors.offWhite,
      onInverseSurface: AppColors.nearBlack,
      inversePrimary: AppColors.electricBlue,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.graphite,
      textTheme: AppTypography.applySans(ThemeData.dark().textTheme),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.nearBlack.withValues(alpha: 0.96),
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.electricBlue.withValues(alpha: 0.24),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.nearBlack.withValues(alpha: 0.9),
        selectedIconTheme: const IconThemeData(color: AppColors.electricBlueSoft),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.electricBlueSoft,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panel,
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
    );

    return base;
  }

  static Color surfaceColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.panel.withValues(alpha: 0.92)
        : AppColors.lightSurface.withValues(alpha: 0.94);
  }
}
