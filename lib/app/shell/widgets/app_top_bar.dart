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
            compactDensity ? AppSpacing.lg : AppSpacing.xl,
          compactDensity ? AppSpacing.lg : AppSpacing.xl,
          compactDensity ? AppSpacing.lg : AppSpacing.xl,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (layoutTier.isMedium && config.actions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                    Expanded(
                      child: Text(
                        config.title,
                        style: (compactDensity
                                ? theme.textTheme.headlineSmall
                                : theme.textTheme.headlineMedium)
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (config.actions.isNotEmpty) ...<Widget>[
                      const SizedBox(width: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: config.actions,
                      ),
                    ],
                  ],
                ),
            if (config.hasBottom) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              config.bottom!,
            ],
          ],
        ),
      ),
    );
  }
}
