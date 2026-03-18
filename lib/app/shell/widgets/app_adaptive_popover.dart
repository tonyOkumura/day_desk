import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_breakpoints.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import 'app_glass_bar_surface.dart';
import 'app_header_icon_button.dart';

class AppAdaptivePopover extends StatelessWidget {
  const AppAdaptivePopover({
    required this.title,
    required this.child,
    this.onReset,
    this.onClose,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onReset;
  final VoidCallback? onClose;

  static Future<void> show({
    required BuildContext context,
    required BuildContext targetContext,
    required LayerLink link,
    required String title,
    required WidgetBuilder builder,
    VoidCallback? onReset,
    double width = 360,
    double maxHeight = 520,
  }) async {
    final bool compact = AppBreakpoints.usesCompactNavigation(
      MediaQuery.sizeOf(context).width,
    );

    if (compact) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (BuildContext sheetContext) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight * 0.92,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: AppAdaptivePopover(
                      title: title,
                      onReset: onReset,
                      onClose: () => Navigator.of(sheetContext).pop(),
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxHeight),
                          child: builder(sheetContext),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
      return;
    }

    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    final Completer<void> completer = Completer<void>();
    late final OverlayEntry entry;

    void dismiss() {
      if (entry.mounted) {
        entry.remove();
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    entry = OverlayEntry(
      builder: (BuildContext overlayContext) {
        final RenderBox? targetBox =
            targetContext.findRenderObject() as RenderBox?;
        final Size overlaySize = MediaQuery.sizeOf(overlay.context);
        final double maxAvailableWidth =
            overlaySize.width - AppSpacing.lg * 2;
        final double resolvedWidth = maxAvailableWidth <= 280
            ? maxAvailableWidth
            : width.clamp(280, maxAvailableWidth).toDouble();
        final Rect anchor = targetBox == null
            ? Rect.zero
            : (targetBox.localToGlobal(Offset.zero) & targetBox.size);
        final Offset position = _resolveOffset(
          anchor: anchor,
          overlaySize: overlaySize,
          width: resolvedWidth,
          maxHeight: maxHeight,
        );

        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: dismiss,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              offset: Offset(position.dx - anchor.left, position.dy - anchor.top),
              child: SizedBox(
                width: resolvedWidth,
                child: Material(
                  color: Colors.transparent,
                  child: AppAdaptivePopover(
                    title: title,
                    onReset: onReset,
                    onClose: dismiss,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxHeight),
                      child: SingleChildScrollView(child: builder(overlayContext)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(entry);
    await completer.future;
  }

  static Offset _resolveOffset({
    required Rect anchor,
    required Size overlaySize,
    required double width,
    required double maxHeight,
  }) {
    const double margin = AppSpacing.lg;
    double dx = anchor.left + anchor.width - width;
    dx = dx.clamp(margin, overlaySize.width - width - margin);

    final double below = anchor.bottom + AppSpacing.sm;
    final double fitsBelow = overlaySize.height - below;
    double dy;
    if (fitsBelow >= maxHeight || below <= overlaySize.height - margin) {
      dy = below;
    } else {
      dy = (anchor.top - maxHeight - AppSpacing.sm).clamp(
        margin,
        overlaySize.height - maxHeight - margin,
      );
    }

    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return AppGlassBarSurface(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (onReset != null) ...<Widget>[
                AppHeaderIconButton(
                  icon: Icons.restart_alt_rounded,
                  tooltip: 'Сбросить',
                  onPressed: onReset,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              AppHeaderIconButton(
                icon: Icons.close_rounded,
                tooltip: 'Закрыть',
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}
