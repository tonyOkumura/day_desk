import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.fieldKey,
    this.width,
    super.key,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Key? fieldKey;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<T>(
            key: fieldKey,
            initialValue: value,
            items: items,
            onChanged: onChanged,
            borderRadius: BorderRadius.circular(20),
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
