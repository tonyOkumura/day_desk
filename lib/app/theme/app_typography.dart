import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String displayFamily = 'Montserrat';
  static const String bodyFamily = 'Montserrat Alternates';
  static const String monoFamily = bodyFamily;

  static TextTheme theme(Brightness brightness) {
    final TextTheme base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true).textTheme
        : ThemeData.light(useMaterial3: true).textTheme;
    final TextTheme displayTextTheme = _withFamily(base, displayFamily);
    final TextTheme bodyTextTheme = _withFamily(base, bodyFamily);

    return displayTextTheme.copyWith(
      bodyLarge: bodyTextTheme.bodyLarge,
      bodyMedium: bodyTextTheme.bodyMedium,
      bodySmall: bodyTextTheme.bodySmall,
      labelLarge: bodyTextTheme.labelLarge,
      labelMedium: bodyTextTheme.labelMedium,
      labelSmall: bodyTextTheme.labelSmall,
      titleSmall: bodyTextTheme.titleSmall,
      titleMedium: bodyTextTheme.titleMedium,
    );
  }

  static TextStyle mono(BuildContext context) {
    return (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
        .copyWith(
          fontFamily: monoFamily,
          letterSpacing: 0.24,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        );
  }

  static TextTheme _withFamily(TextTheme textTheme, String fontFamily) {
    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(fontFamily: fontFamily),
      displayMedium: textTheme.displayMedium?.copyWith(fontFamily: fontFamily),
      displaySmall: textTheme.displaySmall?.copyWith(fontFamily: fontFamily),
      headlineLarge: textTheme.headlineLarge?.copyWith(fontFamily: fontFamily),
      headlineMedium: textTheme.headlineMedium?.copyWith(fontFamily: fontFamily),
      headlineSmall: textTheme.headlineSmall?.copyWith(fontFamily: fontFamily),
      titleLarge: textTheme.titleLarge?.copyWith(fontFamily: fontFamily),
      titleMedium: textTheme.titleMedium?.copyWith(fontFamily: fontFamily),
      titleSmall: textTheme.titleSmall?.copyWith(fontFamily: fontFamily),
      bodyLarge: textTheme.bodyLarge?.copyWith(fontFamily: fontFamily),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontFamily: fontFamily),
      bodySmall: textTheme.bodySmall?.copyWith(fontFamily: fontFamily),
      labelLarge: textTheme.labelLarge?.copyWith(fontFamily: fontFamily),
      labelMedium: textTheme.labelMedium?.copyWith(fontFamily: fontFamily),
      labelSmall: textTheme.labelSmall?.copyWith(fontFamily: fontFamily),
    );
  }
}
