import 'package:flutter/material.dart';

enum AppThemePalette {
  blue,
  green,
  amber,
}

extension AppThemePaletteX on AppThemePalette {
  String get label {
    return switch (this) {
      AppThemePalette.blue => 'Синяя',
      AppThemePalette.green => 'Зелёная',
      AppThemePalette.amber => 'Янтарная',
    };
  }

  String get description {
    return switch (this) {
      AppThemePalette.blue =>
        'Холодная рабочая палитра с акцентом на фокус и ритм.',
      AppThemePalette.green =>
        'Спокойная природная палитра для размеренного планирования.',
      AppThemePalette.amber =>
        'Тёплая палитра с мягкими акцентами и более живым характером.',
    };
  }

  List<Color> get previewColors {
    return switch (this) {
      AppThemePalette.blue => const <Color>[
        Color(0xff3f5f90),
        Color(0xffd6e3ff),
        Color(0xff6f5675),
      ],
      AppThemePalette.green => const <Color>[
        Color(0xff4c662b),
        Color(0xffcdeda3),
        Color(0xff386663),
      ],
      AppThemePalette.amber => const <Color>[
        Color(0xff6d5e0f),
        Color(0xfff8e287),
        Color(0xff43664e),
      ],
    };
  }
}
