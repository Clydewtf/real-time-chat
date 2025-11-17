import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/message_status.dart';
import '../value_objects/message_type.dart';

part 'message.freezed.dart';
part 'message.g.dart';


@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String chatId,
    required String senderId,
    required String content,
    required DateTime createdAt,
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.sent) MessageStatus status,
    DateTime? editedAt,
    String? replyToMessageId,
    String? attachmentUrl,
    String? localTempId,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}