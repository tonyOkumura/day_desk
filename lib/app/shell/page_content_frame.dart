import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_breakpoints.dart';
import '../theme/app_spacing.dart';

enum PageContentWidthPolicy { standard, fluid, immersive }

class PageContentLayout {
  const PageContentLayout({
    required this.tier,
    required this.viewportHeight,
    required this.contentHeight,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.maxContentWidth,
  });

  final AppLayoutTier tier;
  final double viewportHeight;
  final double contentHeight;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double maxContentWidth;
}

typedef PageContentFrameBuilder =
    Widget Function(BuildContext context, PageContentLayout layout);

class PageContentFrame extends StatefulWidget {
  const PageContentFrame({
    required this.storageKey,
    this.child,
    this.builder,
    this.maxContentWidth,
    this.widthPolicy = PageContentWidthPolicy.standard,
    super.key,
  }) : assert(
         child != null || builder != null,
         'PageContentFrame requires either child or builder.',
       );

  final String storageKey;
  final Widget? child;
  final PageContentFrameBuilder? builder;
  final double? maxContentWidth;
  final PageContentWidthPolicy widthPolicy;

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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = MediaQuery.sizeOf(context).width;
        final AppLayoutTier tier = AppBreakpoints.layoutTierForWidth(width);
        final double horizontalPadding = _horizontalPaddingForTier(tier);
        final double topPadding = tier.isCompact ? AppSpacing.lg : AppSpacing.xl;
        final double bottomPadding = tier.isCompact
            ? AppSpacing.lg
            : AppSpacing.xl;
        final double viewportHeight = constraints.maxHeight;
        final double contentHeight =
            (viewportHeight - topPadding - bottomPadding).clamp(0.0, double.infinity);
        final double resolvedMaxContentWidth = _resolvedMaxContentWidth;
        final PageContentLayout layout = PageContentLayout(
          tier: tier,
          viewportHeight: viewportHeight,
          contentHeight: contentHeight,
          horizontalPadding: horizontalPadding,
          topPadding: topPadding,
          bottomPadding: bottomPadding,
          maxContentWidth: resolvedMaxContentWidth,
        );
        final Widget content =
            widget.builder?.call(context, layout) ?? widget.child!;

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
            child: _buildContentWrapper(
              content: content,
              contentHeight: contentHeight,
              maxContentWidth: resolvedMaxContentWidth,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentWrapper({
    required Widget content,
    required double contentHeight,
    required double maxContentWidth,
  }) {
    final Widget constrained = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: contentHeight,
        maxWidth: maxContentWidth,
      ),
      child: content,
    );

    if (widget.widthPolicy == PageContentWidthPolicy.immersive) {
      return constrained;
    }

    return Center(child: constrained);
  }

  double _horizontalPaddingForTier(AppLayoutTier tier) {
    return switch (widget.widthPolicy) {
      PageContentWidthPolicy.standard => switch (tier) {
        AppLayoutTier.compact => AppSpacing.lg,
        AppLayoutTier.medium => AppSpacing.xl,
        AppLayoutTier.wide => AppSpacing.xxl,
      },
      PageContentWidthPolicy.fluid => switch (tier) {
        AppLayoutTier.compact => AppSpacing.lg,
        AppLayoutTier.medium => AppSpacing.lg,
        AppLayoutTier.wide => AppSpacing.xl,
      },
      PageContentWidthPolicy.immersive => 0,
    };
  }

  double get _resolvedMaxContentWidth {
    return switch (widget.widthPolicy) {
      PageContentWidthPolicy.standard =>
        widget.maxContentWidth ?? AppBreakpoints.pageMaxWidth,
      PageContentWidthPolicy.fluid =>
        widget.maxContentWidth ?? AppBreakpoints.pageFluidMaxWidth,
      PageContentWidthPolicy.immersive => double.infinity,
    };
  }

  bool get _showDesktopScrollbar {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }
}
