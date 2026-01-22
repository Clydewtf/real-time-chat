import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';
import '../../../core/utils/theme.dart';


class AttachmentPreview extends StatelessWidget {
  final List<String> urls;
  const AttachmentPreview({super.key, required this.urls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.s),
            child: Image.network(
              urls[index],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: AppTheme.lightOnSurface.withValues(alpha: 0.1),
              ),
            ),
          );
        },
      ),
    );
  }
}