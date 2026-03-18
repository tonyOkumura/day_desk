import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_radii.dart';
import '../../theme/app_theme.dart';

class AppGlassBarSurface extends StatelessWidget {
  const AppGlassBarSurface({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final BorderRadius resolvedRadius = borderRadius ??
        BorderRadius.circular(AppRadii.card);

    return ClipRRect(
      borderRadius: resolvedRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(
              context,
            ).withValues(alpha: isDark ? 0.82 : 0.8),
            borderRadius: resolvedRadius,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.34),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.18 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
