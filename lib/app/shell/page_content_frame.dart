import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_breakpoints.dart';
import '../theme/app_spacing.dart';

class PageContentFrame extends StatelessWidget {
  const PageContentFrame({
    required this.storageKey,
    required this.child,
    super.key,
  });

  final String storageKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool useCompactDensity = width < AppBreakpoints.compactDensity;
    final double horizontalPadding = useCompactDensity
        ? AppSpacing.lg
        : AppSpacing.xl;
    final double bottomPadding = useCompactDensity
        ? AppSpacing.lg
        : AppSpacing.xl;

    return Scrollbar(
      thumbVisibility: _showDesktopScrollbar,
      interactive: _showDesktopScrollbar,
      child: SingleChildScrollView(
        key: PageStorageKey<String>(storageKey),
        primary: true,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          bottomPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.pageMaxWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  bool get _showDesktopScrollbar {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }
}
