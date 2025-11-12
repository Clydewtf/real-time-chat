import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../../../core/utils/theme.dart';


class DateDivider extends StatelessWidget {
  final String text;
  const DateDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppTheme.lightOnSurface.withValues(alpha: 0.3), thickness: 0.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Divider(color: AppTheme.lightOnSurface.withValues(alpha: 0.3), thickness: 0.5),
        ),
      ],
    );
  }
}