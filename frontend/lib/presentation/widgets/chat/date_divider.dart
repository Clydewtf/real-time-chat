import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../../../core/utils/theme.dart';

class DateDivider extends StatelessWidget {
  final String text;

  const DateDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: AppTheme.lightOnSurface.withValues(alpha: 0.6),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppTheme.lightOnSurface.withValues(alpha: 0.2),
              thickness: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Text(text, style: textStyle),
          ),
          Expanded(
            child: Divider(
              color: AppTheme.lightOnSurface.withValues(alpha: 0.2),
              thickness: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
