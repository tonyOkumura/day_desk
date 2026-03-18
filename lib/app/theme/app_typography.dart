import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String displayFamily = 'Montserrat';
  static const String bodyFamily = 'Montserrat Alternates';
  static const String monoFamily = bodyFamily;

  static TextTheme theme(Brightness brightness) {
    final TextTheme base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true).textTheme
        : ThemeData.light(useMaterial3: true).textTheme;
    return base.copyWith(
      displayLarge: _display(base.displayLarge, FontWeight.w800, -1.1),
      displayMedium: _display(base.displayMedium, FontWeight.w800, -0.8),
      displaySmall: _display(base.displaySmall, FontWeight.w700, -0.5),
      headlineLarge: _display(base.headlineLarge, FontWeight.w700, -0.55),
      headlineMedium: _display(base.headlineMedium, FontWeight.w700, -0.35),
      headlineSmall: _display(base.headlineSmall, FontWeight.w700, -0.18),
      titleLarge: _display(base.titleLarge, FontWeight.w700, -0.08),
      titleMedium: _body(base.titleMedium, FontWeight.w700, 0.06),
      titleSmall: _body(base.titleSmall, FontWeight.w700, 0.1),
      bodyLarge: _body(base.bodyLarge, FontWeight.w400, 0.08, height: 1.45),
      bodyMedium: _body(base.bodyMedium, FontWeight.w400, 0.06, height: 1.42),
      bodySmall: _body(base.bodySmall, FontWeight.w400, 0.08, height: 1.35),
      labelLarge: _body(base.labelLarge, FontWeight.w700, 0.12),
      labelMedium: _body(base.labelMedium, FontWeight.w600, 0.16),
      labelSmall: _body(base.labelSmall, FontWeight.w600, 0.18),
    );
  }

  static TextStyle meta(BuildContext context) {
    return (Theme.of(context).textTheme.labelMedium ?? const TextStyle())
        .copyWith(
          fontFamily: bodyFamily,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.24,
          height: 1.2,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        );
  }

  static TextStyle mono(BuildContext context) {
    return meta(context).copyWith(fontFamily: monoFamily);
  }

  static TextStyle? _display(
    TextStyle? style,
    FontWeight weight,
    double letterSpacing,
  ) {
    return style?.copyWith(
      fontFamily: displayFamily,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: 1.08,
    );
  }

  static TextStyle? _body(
    TextStyle? style,
    FontWeight weight,
    double letterSpacing, {
    double? height,
  }) {
    return style?.copyWith(
      fontFamily: bodyFamily,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}
