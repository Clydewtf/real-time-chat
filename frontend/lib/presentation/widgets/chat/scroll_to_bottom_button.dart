import 'package:flutter/material.dart';
import 'package:frontend/core/utils/theme.dart';
import 'package:frontend/presentation/widgets/constants/app_elevation.dart';
import 'package:frontend/presentation/widgets/constants/app_spacing.dart';

class ScrollToBottomButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onPressed;

  const ScrollToBottomButton({
    super.key,
    required this.unreadCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: AppSpacing.l * 2,
            height: AppSpacing.l * 2,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: BoxBorder.all(
                color: Theme.of(context).colorScheme.primary,
              ),
              shape: BoxShape.circle,
              boxShadow: context.shadow(AppElevation.level3),
            ),
            child: Icon(
              Icons.arrow_downward,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: _UnreadBadge(count: unreadCount),
            ),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      child: Center(
        child: Text(text, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}
