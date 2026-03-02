enum MessageStatus { pending, sent, delivered, read, failed }

extension MessageStatusX on MessageStatus {
  static MessageStatus fromString(String value) {
    return MessageStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageStatus.sent,
    );
  }

  String toJson() => name;
}

MessageStatus mergeStatus(MessageStatus local, MessageStatus remote) {
  const order = {
    MessageStatus.pending: 0,
    MessageStatus.sent: 1,
    MessageStatus.delivered: 2,
    MessageStatus.read: 3,
  };

  return order[local]! >= order[remote]! ? local : remote;
}
