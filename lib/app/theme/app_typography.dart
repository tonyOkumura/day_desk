import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme theme(Brightness brightness) {
    final TextTheme base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true).textTheme
        : ThemeData.light(useMaterial3: true).textTheme;
    final TextTheme displayTextTheme = GoogleFonts.montserratTextTheme(base);
    final TextTheme bodyTextTheme =
        GoogleFonts.montserratAlternatesTextTheme(base);

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
    return GoogleFonts.ibmPlexMono(
      textStyle: Theme.of(context).textTheme.bodyMedium,
      letterSpacing: 0.2,
    );
  }
}
