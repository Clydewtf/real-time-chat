enum MessageStatus { pending, sent, delivered, read }

extension MessageStatusX on MessageStatus {
  static MessageStatus fromString(String value) {
    return MessageStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageStatus.sent,
    );
  }

  String toJson() => name;
}