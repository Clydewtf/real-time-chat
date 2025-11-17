import 'package:drift/drift.dart';
import 'package:frontend/data/datasources/local/drift/app_database.dart';
import '../../../../domain/entities/message.dart';
import '../../../../domain/value_objects/message_status.dart';
import '../../../../domain/value_objects/message_type.dart';


extension MessageDatabaseMapper on Message {
  MessagesTableCompanion toCompanion() {
    return MessagesTableCompanion(
      id: Value(id),
      chatId: Value(chatId),
      senderId: Value(senderId),
      content: Value(content),
      createdAt: Value(createdAt),
      type: Value(type.name),
      status: Value(status.name),
      editedAt: Value(editedAt),
      replyToMessageId: Value(replyToMessageId),
      attachmentUrl: Value(attachmentUrl),
      localTempId: Value(localTempId),
    );
  }
}

extension MessageRowMapper on MessagesTableData {
  Message toDomain() {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      createdAt: createdAt,
      type: MessageTypeX.fromString(type),
      status: MessageStatusX.fromString(status),
      editedAt: editedAt,
      replyToMessageId: replyToMessageId,
      attachmentUrl: attachmentUrl,
      localTempId: localTempId,
    );
  }
}