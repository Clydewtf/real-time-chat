import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:frontend/data/datasources/local/drift/app_database.dart';
import '../../../../domain/entities/chat.dart';


extension ChatDatabaseMapper on Chat {
  ChatsTableCompanion toCompanion() {
    return ChatsTableCompanion(
      id: Value(id),
      participantIds: Value(jsonEncode(participantIds)),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastMessageId: Value(lastMessageId),
      title: Value(title),
      avatarUrl: Value(avatarUrl),
      description: Value(description),
    );
  }
}

extension ChatRowMapper on ChatsTableData {
  Chat toDomain() {
    return Chat(
      id: id,
      participantIds: List<String>.from(jsonDecode(participantIds)),
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastMessageId: lastMessageId,
      title: title,
      avatarUrl: avatarUrl,
      description: description,
    );
  }
}