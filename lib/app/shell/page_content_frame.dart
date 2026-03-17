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
    return SingleChildScrollView(
      key: PageStorageKey<String>(storageKey),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.pageMaxWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}
