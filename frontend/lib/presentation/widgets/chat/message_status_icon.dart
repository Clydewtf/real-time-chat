import 'package:flutter/material.dart';
import '../../../core/utils/theme.dart';


enum MessageStatus { sent, delivered, read, pending, error }

class MessageStatusIcon extends StatelessWidget {
  final MessageStatus status;
  const MessageStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Icon icon;
    switch (status) {
      case MessageStatus.sent:
        icon = Icon(Icons.check, size: 16, color: AppTheme.lightOnPrimary);
        break;
      case MessageStatus.delivered:
        icon = Icon(Icons.done_all, size: 16, color: AppTheme.lightOnPrimary);
        break;
      case MessageStatus.read:
        icon = Icon(Icons.done_all, size: 16, color: Colors.blue);
        break;
      case MessageStatus.pending:
        icon = Icon(Icons.access_time, size: 16, color: AppTheme.lightOnPrimary);
        break;
      case MessageStatus.error:
        icon = Icon(Icons.error, size: 16, color: AppTheme.lightError);
        break;
    }
    return icon;
  }
}