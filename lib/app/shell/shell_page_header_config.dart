import 'package:flutter/widgets.dart';

class ShellPageHeaderConfig {
  const ShellPageHeaderConfig({
    required this.title,
    this.actions = const <Widget>[],
    this.bottom,
  });

  final String title;
  final List<Widget> actions;
  final Widget? bottom;

  bool get hasBottom => bottom != null;
}
