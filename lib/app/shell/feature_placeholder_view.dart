import 'package:flutter/material.dart';

import '../../core/widgets/adaptive_section_grid.dart';
import '../../core/widgets/app_section_card.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class FeaturePlaceholderView extends StatelessWidget {
  const FeaturePlaceholderView({
    required this.title,
    required this.summary,
    required this.highlights,
    required this.nextMilestone,
    super.key,
  });

  final String title;
  final String summary;
  final List<String> highlights;
  final String nextMilestone;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AdaptiveSectionGrid(
      children: <Widget>[
        AppSectionCard(
          title: title,
          description: summary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Sprint 0 foundation',
                  style: AppTypography.mono(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSectionCard(
          title: 'Что уже заложено',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...highlights.map(
                (String item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(item, style: textTheme.bodyMedium)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSectionCard(
          title: 'Следующий шаг',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(nextMilestone, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
