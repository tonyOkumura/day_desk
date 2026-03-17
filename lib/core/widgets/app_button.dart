import 'package:flutter/material.dart';

import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, tonal, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isExpanded = false,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isExpanded;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final Widget content = isLoading
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );

    final ButtonStyle commonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 48)),
      padding: const WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: commonStyle,
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: commonStyle,
        child: content,
      ),
      AppButtonVariant.tonal => FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        style: commonStyle,
        child: content,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: commonStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll<Color>(colorScheme.error),
          foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onError),
        ),
        child: content,
      ),
    };

    if (!isExpanded) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
