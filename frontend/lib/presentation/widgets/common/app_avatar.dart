import 'package:flutter/material.dart';
import '../constants/app_radius.dart';


class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool isOnline;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.size = 48,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.l),
          child: imageUrl != null
              ? Image.network(imageUrl!, width: size, height: size, fit: BoxFit.cover)
              : Container(
                  width: size,
                  height: size,
                  color: scheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person, size: size * 0.6, color: scheme.primary),
                ),
        ),
        if (isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}