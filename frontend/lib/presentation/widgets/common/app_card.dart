import 'package:flutter/material.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';


class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: BorderRadius.circular(radius ?? AppRadius.l),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: child,
    );

    return onTap != null
        ? InkWell(
            borderRadius: BorderRadius.circular(radius ?? AppRadius.l),
            onTap: onTap,
            child: content,
          )
        : content;
  }
}