import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../config/app_breakpoints.dart';

class AdaptiveSectionGrid extends StatelessWidget {
  const AdaptiveSectionGrid({
    required this.children,
    this.spacing = AppSpacing.xl,
    this.runSpacing = AppSpacing.xl,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (children.isEmpty) {
          return const SizedBox.shrink();
        }

        final AppLayoutTier tier = AppBreakpoints.layoutTierForWidth(
          constraints.maxWidth,
        );
        final int columns = tier.isCompact ? 1 : 2;

        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withVerticalSpacing(children),
          );
        }

        final double itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map(
                (Widget child) => SizedBox(
                  width: itemWidth,
                  child: child,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  List<Widget> _withVerticalSpacing(List<Widget> widgets) {
    final List<Widget> result = <Widget>[];
    for (int index = 0; index < widgets.length; index++) {
      result.add(widgets[index]);
      if (index < widgets.length - 1) {
        result.add(const SizedBox(height: AppSpacing.xl));
      }
    }
    return result;
  }
}
