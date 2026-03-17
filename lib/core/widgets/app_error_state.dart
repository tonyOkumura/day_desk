import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'app_button.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.cloud_off_rounded,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 28, color: colorScheme.error),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
        if (actionLabel != null && onAction != null) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: actionLabel!,
            onPressed: onAction,
            variant: AppButtonVariant.secondary,
            icon: Icons.refresh_rounded,
          ),
        ],
      ],
    );
  }
}
