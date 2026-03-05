import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/constants/app_radius.dart';
import 'package:intl/intl.dart';
import '../constants/app_spacing.dart';
import '../../../core/utils/theme.dart';

class DateDivider extends StatelessWidget {
  final String text;

  const DateDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppTheme.lightOnSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.m * 2),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.lightOnSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

String formatDateSeparator(DateTime date) {
  final localDate = date.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(localDate.year, localDate.month, localDate.day);
  final difference = today.difference(messageDay).inDays;

  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  if (localDate.year == now.year) {
    return DateFormat('d MMMM').format(localDate);
  }

  return DateFormat('d MMMM yyyy').format(localDate);
}
