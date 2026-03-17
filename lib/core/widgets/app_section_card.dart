import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'app_surface_card.dart';

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    required this.title,
    required this.child,
    this.description,
    this.trailing,
    super.key,
  });

  final String title;
  final String? description;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (description != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Text(description!, style: textTheme.bodyLarge),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}
