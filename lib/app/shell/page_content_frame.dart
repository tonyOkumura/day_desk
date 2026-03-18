import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_breakpoints.dart';
import '../theme/app_spacing.dart';

class PageContentFrame extends StatefulWidget {
  const PageContentFrame({
    required this.storageKey,
    required this.child,
    this.maxContentWidth = AppBreakpoints.pageMaxWidth,
    super.key,
  });

  final String storageKey;
  final Widget child;
  final double maxContentWidth;

  @override
  State<PageContentFrame> createState() => _PageContentFrameState();
}

class _PageContentFrameState extends State<PageContentFrame> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final AppLayoutTier tier = AppBreakpoints.layoutTierForWidth(width);
    final double horizontalPadding = switch (tier) {
      AppLayoutTier.compact => AppSpacing.lg,
      AppLayoutTier.medium => AppSpacing.xl,
      AppLayoutTier.wide => AppSpacing.xxl,
    };
    final double topPadding = tier.isCompact ? AppSpacing.lg : AppSpacing.xl;
    final double bottomPadding = tier.isCompact ? AppSpacing.lg : AppSpacing.xl;

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: _showDesktopScrollbar,
      interactive: _showDesktopScrollbar,
      child: SingleChildScrollView(
        key: PageStorageKey<String>(widget.storageKey),
        controller: _scrollController,
        primary: false,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          topPadding,
          horizontalPadding,
          bottomPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.maxContentWidth,
            ),
            child: widget.child,
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
