import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'app_button.dart';

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AppConfirmDialog(
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
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        AppButton(
          label: cancelLabel,
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppButton(
          label: confirmLabel,
          variant: isDestructive
              ? AppButtonVariant.danger
              : AppButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
