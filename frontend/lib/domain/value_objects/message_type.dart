enum MessageType { text, image, file, system }

extension MessageTypeX on MessageType {
  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageType.text,
    );
  }

  String toJson() => name;
}