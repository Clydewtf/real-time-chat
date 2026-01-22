import 'package:drift/drift.dart';
import '../drift/app_database.dart';
import '../drift/chat_mapper.dart';
import '../../../../domain/entities/chat.dart';


class ChatLocalDatasource {
  final AppDatabase db;
  ChatLocalDatasource(this.db);

  Future<void> saveChat(Chat chat) async {
    await db.into(db.chatsTable).insertOnConflictUpdate(
          chat.toCompanion(),
        );
  }

  Future<Chat?> getChatById(String chatId) async {
    final row = await (db.select(db.chatsTable)
          ..where((tbl) => tbl.id.equals(chatId)))
        .getSingleOrNull();

    return row?.toDomain();
  }

  /// Find existing chat between two users
  Future<Chat?> findDirectChat(String userA, String userB) async {
    final rows = await db.select(db.chatsTable).get();
    for (final row in rows) {
      final chat = row.toDomain();
      if (chat.participantIds.toSet().containsAll([userA, userB]) &&
          chat.participantIds.length == 2) {
        return chat;
      }
    }
    return null;
  }

  /// Return all chats where that user exists
  Future<List<Chat>> getUserChats(String userId) async {
    final rows = await db.select(db.chatsTable).get();
    return rows
        .map((row) => row.toDomain())
        .where((chat) => chat.participantIds.contains(userId))
        .toList();
  }

  /// Subscription to chats
  Stream<List<Chat>> watchUserChats(String userId) {
    return db.select(db.chatsTable).watch().map(
      (rows) => rows
          .map((row) => row.toDomain())
          .where((chat) => chat.participantIds.contains(userId))
          .toList()
        ..sort((a, b) {
          final aTime = a.updatedAt ?? a.createdAt;
          final bTime = b.updatedAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        }),
    );
  }

  Future<void> updateLastMessageId(String chatId, String messageId) async {
    await (db.update(db.chatsTable)..where((tbl) => tbl.id.equals(chatId)))
        .write(
      ChatsTableCompanion(
        lastMessageId: Value(messageId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteChat(String chatId) async {
    await (db.delete(db.chatsTable)
          ..where((tbl) => tbl.id.equals(chatId)))
        .go();
  }
}