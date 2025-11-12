import 'package:flutter/material.dart';
import '../common/app_card.dart';
import 'message_status_icon.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radius.dart';
import '../../../core/utils/theme.dart';


enum BubbleType { incoming, outgoing }

class MessageBubble extends StatelessWidget {
  final String text;
  final BubbleType type;
  final bool isLastInGroup;
  final MessageStatus status;

  const MessageBubble({
    super.key,
    required this.text,
    required this.type,
    this.isLastInGroup = true,
    this.status = MessageStatus.sent,
  });

  @override
  Widget build(BuildContext context) {
    final isOutgoing = type == BubbleType.outgoing;
    final bgColor = isOutgoing ? AppTheme.lightPrimary : AppTheme.lightSurface;
    final textColor = isOutgoing ? AppTheme.lightOnPrimary : AppTheme.lightOnSurface;

    return Row(
      mainAxisAlignment: isOutgoing ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isOutgoing) const SizedBox(width: AppSpacing.m),
        Flexible(
          child: AppCard(
            color: bgColor,
            radius: AppRadius.m,
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: textColor)),
                if (isOutgoing)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: MessageStatusIcon(status: status),
                  ),
              ],
            ),
          ),
        ),
        if (isOutgoing) const SizedBox(width: AppSpacing.m),
      ],
    );
  }
}