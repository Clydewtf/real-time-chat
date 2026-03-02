import 'package:drift/drift.dart';
import '../../../../domain/entities/message.dart';
import '../../../../domain/value_objects/message_status.dart';
import '../drift/message_mapper.dart';
import '../drift/app_database.dart';

class MessageLocalDatasource {
  final AppDatabase db;
  MessageLocalDatasource(this.db);

  /// Save message to local db
  Future<void> saveMessage(Message message) async {
    await db
        .into(db.messagesTable)
        .insertOnConflictUpdate(message.toCompanion());
  }

  /// Return messages from chat from local db
  Future<List<Message>> getMessages(String chatId, limit) async {
    final rows =
        await (db.select(db.messagesTable)
              ..where((tbl) => tbl.chatId.equals(chatId))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
              ..limit(limit))
            .get();

    return rows.map((row) => row.toDomain()).toList();
  }

  /// Return older messages from chat from loal db
  Future<List<Message>> getOlderMessages(
    String chatId,
    DateTime before,
    int limit,
  ) async {
    final rows =
        await (db.select(db.messagesTable)
              ..where(
                (tbl) =>
                    tbl.chatId.equals(chatId) &
                    tbl.createdAt.isSmallerThanValue(before),
              )
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
              ..limit(limit))
            .get();

    return rows.map((row) => row.toDomain()).toList();
  }

  /// Update message status locally
  Future<void> updateMessageStatus(
    String messageId,
    MessageStatus status,
  ) async {
    await (db.update(db.messagesTable)
          ..where((tbl) => tbl.id.equals(messageId)))
        .write(MessagesTableCompanion(status: Value(status.name)));
  }

  /// Update messages status locally by localIds
  Future<void> updateMessagesStatus(
    List<String> localIds,
    MessageStatus status,
  ) async {
    if (localIds.isEmpty) return;

    await (db.update(db.messagesTable)..where((tbl) => tbl.id.isIn(localIds)))
        .write(MessagesTableCompanion(status: Value(status.name)));
  }

  /// Update messages status locally by remoteIds
  Future<void> updateMessagesStatusByRemoteIds(
    List<String> remoteIds,
    MessageStatus status,
  ) async {
    if (remoteIds.isEmpty) return;

    await (db.update(db.messagesTable)
          ..where((tbl) => tbl.remoteId.isIn(remoteIds)))
        .write(MessagesTableCompanion(status: Value(status.name)));
  }

  /// Delete message from local db
  Future<void> deleteMessage(String messageId) async {
    await (db.delete(
      db.messagesTable,
    )..where((tbl) => tbl.id.equals(messageId))).go();
  }

  /// Delete all messages from chat locally
  Future<void> deleteChatMessages(String chatId) async {
    await (db.delete(
      db.messagesTable,
    )..where((tbl) => tbl.chatId.equals(chatId))).go();
  }

  /// Update message remote id
  Future<void> updateAfterRemoteSync({
    required String localId,
    required String remoteId,
  }) async {
    await (db.update(db.messagesTable)..where((tbl) => tbl.id.equals(localId)))
        .write(MessagesTableCompanion(remoteId: Value(remoteId)));
  }

  /// Return message by local temp id from local db
  Future<Message?> findByLocalTempId(String localTempId) async {
    final row = await (db.select(
      db.messagesTable,
    )..where((tbl) => tbl.localTempId.equals(localTempId))).getSingleOrNull();

    return row?.toDomain();
  }

  /// Return message by remote id from local db
  Future<Message?> findByRemoteId(String remoteId) async {
    final row = await (db.select(
      db.messagesTable,
    )..where((tbl) => tbl.remoteId.equals(remoteId))).getSingleOrNull();

    return row?.toDomain();
  }

  /// Subscription to messages from local db
  Stream<List<Message>> watchMessages(String chatId) {
    return (db.select(db.messagesTable)
          ..where((tbl) => tbl.chatId.equals(chatId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch()
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
