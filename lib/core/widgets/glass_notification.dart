import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

class GlassNotification extends StatelessWidget {
  const GlassNotification({
    required this.title,
    this.message,
    this.icon,
    this.color,
    this.onClose,
    this.closeButtonKey,
    super.key,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onClose;
  final Key? closeButtonKey;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color resolvedColor = color ?? colorScheme.primary;
    final bool isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: isDark ? 0.82 : 0.9),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: Color.alphaBlend(
                resolvedColor.withValues(alpha: 0.12),
                colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.16 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: resolvedColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(
                    color: resolvedColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  icon ?? Icons.info_rounded,
                  color: resolvedColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (onClose != null)
                          GestureDetector(
                            key: closeButtonKey,
                            onTap: onClose,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: AppSpacing.sm,
                                top: 2,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (message != null && message!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        message!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
