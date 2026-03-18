import 'package:flutter/material.dart';

import '../../theme/app_radii.dart';

class AppHeaderIconButton extends StatelessWidget {
  const AppHeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isActive = false,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isActive;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foreground = onPressed == null
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
        : isActive
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    final Color background = onPressed == null
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.24)
        : isActive
        ? colorScheme.primaryContainer.withValues(alpha: 0.72)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.52);

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 450),
      child: Semantics(
        button: true,
        label: semanticLabel ?? tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Ink(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: isActive
                      ? colorScheme.primary.withValues(alpha: 0.22)
                      : colorScheme.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Icon(icon, size: 20, color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}
