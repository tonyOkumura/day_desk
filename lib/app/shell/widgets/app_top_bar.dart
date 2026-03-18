import 'package:flutter/material.dart';

import '../../../core/config/app_breakpoints.dart';
import '../../theme/app_spacing.dart';
import '../shell_page_header_config.dart';
import 'app_glass_bar_surface.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    required this.config,
    required this.layoutTier,
    required this.pageKey,
    super.key,
  });

  final ShellPageHeaderConfig config;
  final AppLayoutTier layoutTier;
  final Key pageKey;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool compactDensity = layoutTier.isCompact;
    final bool hasTitle = config.title.trim().isNotEmpty;
    final bool showTopRow = hasTitle || config.actions.isNotEmpty;
    final bool bottomOnly = !showTopRow && config.hasBottom;
    final double verticalPaddingTop = bottomOnly
        ? AppSpacing.md
        : (showTopRow
              ? (compactDensity ? AppSpacing.lg : AppSpacing.xl)
              : AppSpacing.lg);
    final double verticalPaddingBottom = bottomOnly
        ? (compactDensity ? AppSpacing.md : AppSpacing.lg)
        : (compactDensity ? AppSpacing.lg : AppSpacing.xl);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        compactDensity ? AppSpacing.lg : AppSpacing.xl,
        AppSpacing.md,
        compactDensity ? AppSpacing.lg : AppSpacing.xl,
        AppSpacing.md,
      ),
      child: AppGlassBarSurface(
        key: pageKey,
        padding: EdgeInsets.fromLTRB(
          compactDensity ? AppSpacing.lg : AppSpacing.xl,
          verticalPaddingTop,
          compactDensity ? AppSpacing.lg : AppSpacing.xl,
          verticalPaddingBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showTopRow)
              if (layoutTier.isMedium && config.actions.isNotEmpty && hasTitle)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (hasTitle)
                      Text(
                        config.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: config.actions,
                    ),
                  ],
                )
              else
                Row(
                  children: <Widget>[
                    if (hasTitle)
                      Expanded(
                        child: Text(
                          config.title,
                          style:
                              (compactDensity
                                      ? theme.textTheme.headlineSmall
                                      : theme.textTheme.headlineMedium)
                                  ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      )
                    else
                      const Spacer(),
                    if (config.actions.isNotEmpty) ...<Widget>[
                      if (hasTitle) const SizedBox(width: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: config.actions,
                      ),
                    ],
                  ],
                ),
            if (config.hasBottom) ...<Widget>[
              if (showTopRow) const SizedBox(height: AppSpacing.lg),
              config.bottom!,
            ],
          ],
        ),
      ),
    );
  }
}
