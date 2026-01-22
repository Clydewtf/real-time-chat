import 'package:flutter/material.dart';
import '../common/app_avatar.dart';
import '../common/app_card.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../../../core/utils/theme.dart';


class ChatCard extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String avatarUrl;
  final VoidCallback? onTap;

  const ChatCard({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    required this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      onTap: onTap,
      child: Row(
        children: [
          AppAvatar(imageUrl: avatarUrl, size: 24),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  lastMessage,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppTheme.lightOnSurface.withValues(alpha: 0.7)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Column(
            children: [
              Text(time, style: Theme.of(context).textTheme.bodySmall),
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.lightSecondary,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppTheme.lightOnSecondary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}