import 'package:flutter/material.dart';

import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import 'app_surface_card.dart';

class AppExpandableSection extends StatelessWidget {
  const AppExpandableSection({
    required this.header,
    required this.child,
    required this.expanded,
    required this.onExpandedChanged,
    this.cardKey,
    super.key,
  });

  final Widget header;
  final Widget child;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      key: cardKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: key,
              borderRadius: BorderRadius.circular(AppRadii.card),
              onTap: () => onExpandedChanged(!expanded),
              child: Padding(
                padding: EdgeInsets.zero,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: header),
                    const SizedBox(width: AppSpacing.md),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              heightFactor: expanded ? 1 : 0,
              child: IgnorePointer(
                ignoring: !expanded,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
