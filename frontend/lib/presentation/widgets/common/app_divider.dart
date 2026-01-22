import 'package:flutter/material.dart';


class AppDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const AppDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Divider(
      thickness: 0.5,
      color: scheme.onSurface.withValues(alpha: 0.15),
      indent: indent,
      endIndent: endIndent,
    );
  }
}