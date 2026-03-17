import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String sansFamily = 'IBM Plex Sans';
  static const String monoFamily = 'IBM Plex Mono';

  static TextTheme applySans(TextTheme base) {
    return base.apply(
      fontFamily: sansFamily,
      bodyColor: null,
      displayColor: null,
    );
  }

  static TextStyle mono(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontFamily: monoFamily,
      fontFamilyFallback: const <String>[
        'Roboto Mono',
        'monospace',
      ],
      letterSpacing: 0.2,
    );
  }
}
