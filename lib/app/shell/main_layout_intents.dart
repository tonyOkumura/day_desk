import 'package:flutter/widgets.dart';

import '../navigation/app_destination.dart';

class NavigateToDestinationIntent extends Intent {
  const NavigateToDestinationIntent(this.destination);

  final AppDestination destination;
}

class ToggleSidebarIntent extends Intent {
  const ToggleSidebarIntent();
}

class DismissTransientUiIntent extends Intent {
  const DismissTransientUiIntent();
}
