import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({required this.title, this.message, super.key});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        if (message != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(
            message!,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
