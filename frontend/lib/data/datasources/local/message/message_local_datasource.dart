import 'package:drift/drift.dart';
import '../../../../domain/entities/message.dart';
import '../../../../domain/value_objects/message_status.dart';
import '../drift/message_mapper.dart';
import '../drift/app_database.dart';


class MessageLocalDatasource {
  final AppDatabase db;
  MessageLocalDatasource(this.db);

  Future<void> saveMessage(Message message) async {
    await db.into(db.messagesTable).insertOnConflictUpdate(
      message.toCompanion(),
    );
  }

  Future<List<Message>> getMessages(String chatId) async {
    final rows = await (db.select(db.messagesTable)
          ..where((tbl) => tbl.chatId.equals(chatId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
        .get();

    return rows.map((row) => row.toDomain()).toList();
  }

  Future<void> updateMessageStatus(
    String messageId,
    MessageStatus status,
  ) async {
    await (db.update(db.messagesTable)
          ..where((tbl) => tbl.id.equals(messageId)))
        .write(
      MessagesTableCompanion(
        status: Value(status.name),
      ),
    );
  }

  Future<void> deleteMessage(String messageId) async {
    await (db.delete(db.messagesTable)
          ..where((tbl) => tbl.id.equals(messageId)))
        .go();
  }

  Future<void> deleteChatMessages(String chatId) async {
    await (db.delete(db.messagesTable)
          ..where((tbl) => tbl.chatId.equals(chatId)))
        .go();
  }
}