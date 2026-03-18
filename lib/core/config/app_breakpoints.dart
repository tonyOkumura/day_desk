enum AppLayoutTier {
  compact,
  medium,
  wide;

  bool get isCompact => this == AppLayoutTier.compact;
  bool get isMedium => this == AppLayoutTier.medium;
  bool get isWide => this == AppLayoutTier.wide;
}

abstract final class AppBreakpoints {
  static const double compactDensity = 640;
  static const double compactHeader = 720;
  static const double compactNavigation = 900;
  static const double pageMaxWidth = 1200;

  static AppLayoutTier layoutTierForWidth(double width) {
    if (width < compactHeader) {
      return AppLayoutTier.compact;
    }
    if (width < pageMaxWidth) {
      return AppLayoutTier.medium;
    }
    return AppLayoutTier.wide;
  }

  static bool usesCompactNavigation(double width) {
    return width < compactNavigation;
  }
}
