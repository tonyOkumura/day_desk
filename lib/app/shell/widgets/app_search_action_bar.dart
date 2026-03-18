import 'package:flutter/material.dart';

import '../../../core/config/app_breakpoints.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';

class AppSearchActionBar extends StatelessWidget {
  const AppSearchActionBar({
    required this.controller,
    required this.onChanged,
    this.hintText = 'Поиск...',
    this.leadingActions = const <Widget>[],
    this.trailingActions = const <Widget>[],
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final List<Widget> leadingActions;
  final List<Widget> trailingActions;

  @override
  Widget build(BuildContext context) {
    final AppLayoutTier tier = AppBreakpoints.layoutTierForWidth(
      MediaQuery.sizeOf(context).width,
    );

    if (!tier.isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SearchField(
            controller: controller,
            hintText: hintText,
            onChanged: onChanged,
          ),
          if (leadingActions.isNotEmpty || trailingActions.isNotEmpty) ...<Widget>[
            SizedBox(height: tier.isCompact ? AppSpacing.md : AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (leadingActions.isNotEmpty)
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: leadingActions,
                    ),
                  ),
                if (leadingActions.isNotEmpty && trailingActions.isNotEmpty)
                  const SizedBox(width: AppSpacing.md),
                if (trailingActions.isNotEmpty)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        alignment: WrapAlignment.end,
                        children: trailingActions,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      );
    }

    return Row(
      children: <Widget>[
        ...leadingActions,
        if (leadingActions.isNotEmpty) const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SearchField(
            controller: controller,
            hintText: hintText,
            onChanged: onChanged,
          ),
        ),
        if (trailingActions.isNotEmpty) const SizedBox(width: AppSpacing.sm),
        ..._withHorizontalSpacing(trailingActions),
      ],
    );
  }

  List<Widget> _withHorizontalSpacing(List<Widget> children) {
    if (children.isEmpty) {
      return const <Widget>[];
    }

    final List<Widget> spacedChildren = <Widget>[];
    for (int index = 0; index < children.length; index++) {
      spacedChildren.add(children[index]);
      if (index < children.length - 1) {
        spacedChildren.add(const SizedBox(width: AppSpacing.sm));
      }
    }
    return spacedChildren;
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return TextField(
      key: const Key('shell-header-search-field'),
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: hintText,
        filled: true,
        fillColor: colorScheme.surface.withValues(alpha: 0.74),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Очистить поиск',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
