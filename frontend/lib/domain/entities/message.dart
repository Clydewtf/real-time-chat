import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/message_status.dart';
import '../value_objects/message_type.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    // Local UUID (always exists)
    required String id,

    // Remote UUID (null until synced)
    String? remoteId,
    required String chatId,
    required String senderId,
    required String content,
    required DateTime createdAt,
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.sent) MessageStatus status,
    DateTime? editedAt,
    String? replyToMessageId,
    String? attachmentUrl,

    /// Used to match local ↔ remote
    String? localTempId,
  }) = _Message;

  // factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  factory Message.fromJson(Map<String, dynamic> json) {
    final remoteId = json['id'] as String;
    final localTempId = json['local_temp_id'] as String?;

    return Message(
      id: localTempId ?? remoteId,

      remoteId: remoteId,

      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at']),

      type: MessageTypeX.fromString(json['type']),
      status: MessageStatusX.fromString(json['status']),

      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'])
          : null,

      replyToMessageId: json['reply_to_message_id'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      localTempId: localTempId,
    );
  }
}
