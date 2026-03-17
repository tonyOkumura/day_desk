import 'dart:ui';

import 'package:flutter/material.dart';

class DayDeskScrollBehavior extends MaterialScrollBehavior {
  const DayDeskScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    ...super.dragDevices,
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
