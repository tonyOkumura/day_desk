import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'app_button.dart';

class AppConfirmSheet extends StatelessWidget {
  const AppConfirmSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Отмена',
    this.isDestructive = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Отмена',
    bool isDestructive = false,
  }) async {
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppConfirmSheet(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          isDestructive: isDestructive,
        );
      },
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: confirmLabel,
              variant: isDestructive
                  ? AppButtonVariant.danger
                  : AppButtonVariant.primary,
              isExpanded: true,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: cancelLabel,
              variant: AppButtonVariant.secondary,
              isExpanded: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
