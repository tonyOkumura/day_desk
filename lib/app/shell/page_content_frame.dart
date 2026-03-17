import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_breakpoints.dart';
import '../theme/app_spacing.dart';

class PageContentFrame extends StatefulWidget {
  const PageContentFrame({
    required this.storageKey,
    required this.child,
    super.key,
  });

  final String storageKey;
  final Widget child;

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
    final bool useCompactDensity = width < AppBreakpoints.compactDensity;
    final double horizontalPadding = useCompactDensity
        ? AppSpacing.lg
        : AppSpacing.xl;
    final double bottomPadding = useCompactDensity
        ? AppSpacing.lg
        : AppSpacing.xl;

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
          0,
          horizontalPadding,
          bottomPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.pageMaxWidth,
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
