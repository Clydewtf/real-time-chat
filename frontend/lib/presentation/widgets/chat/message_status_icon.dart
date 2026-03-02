import 'package:flutter/material.dart';
import '../../../domain/value_objects/message_status.dart';

class MessageStatusIcon extends StatelessWidget {
  final MessageStatus status;
  const MessageStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Icon icon;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final error = Theme.of(context).colorScheme.error;

    switch (status) {
      case MessageStatus.sent:
        icon = Icon(Icons.check, size: 16, color: onPrimary);
        break;
      case MessageStatus.delivered:
        icon = Icon(Icons.done, size: 16, color: onPrimary);
        break;
      case MessageStatus.read:
        icon = Icon(Icons.done_all, size: 16, color: onPrimary);
        break;
      case MessageStatus.pending:
        icon = Icon(Icons.access_time, size: 16, color: onPrimary);
        break;
      case MessageStatus.failed:
        icon = Icon(Icons.error, size: 16, color: error);
        break;
    }
    return icon;
  }
}
