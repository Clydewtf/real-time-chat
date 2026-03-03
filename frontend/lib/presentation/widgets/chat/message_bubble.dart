import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/value_objects/message_status.dart';
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
  final DateTime timestamp;

  const MessageBubble({
    super.key,
    required this.text,
    required this.type,
    required this.timestamp,
    this.isLastInGroup = true,
    this.status = MessageStatus.sent,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm').format(timestamp.toLocal());
    final isOutgoing = type == BubbleType.outgoing;
    final maxBubbleWidth =
        MediaQuery.of(context).size.width * (isOutgoing ? 0.65 : 0.75);
    final bgColor = isOutgoing ? AppTheme.lightPrimary : AppTheme.lightSurface;
    final textColor = isOutgoing
        ? AppTheme.lightOnPrimary
        : AppTheme.lightOnSurface;

    return Row(
      mainAxisAlignment: isOutgoing
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isOutgoing) const SizedBox(width: AppSpacing.m),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: AppCard(
              color: bgColor,
              radius: AppRadius.l,
              padding: const EdgeInsets.all(AppSpacing.s + AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    text,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: textColor),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeString,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                      if (isOutgoing) ...[
                        const SizedBox(width: 4),
                        MessageStatusIcon(status: status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isOutgoing) const SizedBox(width: AppSpacing.m),
      ],
    );
  }
}
