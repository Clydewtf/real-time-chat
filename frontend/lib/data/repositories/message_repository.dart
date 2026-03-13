import 'dart:async';
import 'package:frontend/data/datasources/local/drift/message_mapper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/entities/message.dart';
import '../../domain/value_objects/message_status.dart';
import '../datasources/local/message/message_local_datasource.dart';
import '../datasources/remote/message/message_remote_datasource.dart';
import 'chat_repository.dart';

class MessageRepository {
  final MessageLocalDatasource local;
  final MessageRemoteDatasource remote;
  final ChatRepository chatRepository;
  final Map<String, Message> _messageCache = {};

  MessageRepository({
    required this.local,
    required this.remote,
    required this.chatRepository,
  });

  void cacheMessage(Message message) {
    final key = message.remoteId ?? message.id;
    _messageCache[key] = message;
  }

  void cacheMessages(List<Message> messages) {
    for (final msg in messages) {
      final key = msg.remoteId ?? msg.id;
      _messageCache[key] = msg;
    }
  }

  Message? getCachedMessage(String id) {
    final msg = _messageCache[id];
    return msg;
  }

  Future<Message?> getMessageById(String messageId) async {
    final cached = getCachedMessage(messageId);
    if (cached != null) return cached;

    final localMsg = await local.findByRemoteId(messageId);
    if (localMsg != null) {
      cacheMessage(localMsg);
    }

    return localMsg;
  }

  /// Return latest messages
  Future<List<Message>> getLatestMessages(String chatId, int limit) async {
    final latest = await local.getMessages(chatId, limit);
    cacheMessages(latest);
    return latest;
  }

  /// Return older messages
  Future<List<Message>> getOlderMessages(
    String chatId,
    DateTime before,
    int limit,
  ) async {
    final older = await local.getOlderMessages(chatId, before, limit);
    cacheMessages(older);
    return older;
  }

  /// OFFLINE-FIRST send message
  Future<void> sendMessage({
    required GraphQLClient client,
    required Message message,
  }) async {
    // 1. Save locally as pending
    await local.saveMessage(message.copyWith(status: MessageStatus.pending));
    cacheMessage(message);

    try {
      // 2. Send remotely
      final remoteJson = await remote.sendMessage(
        chatId: message.chatId,
        content: message.content,
        localTempId: message.localTempId ?? message.id,
        client: client,
      );

      final remoteMessage = Message.fromJson(remoteJson);

      // 3. Update local message after sync
      await local.updateAfterRemoteSync(
        localId: message.id,
        remoteId: remoteMessage.id,
      );

      cacheMessage(remoteMessage);

      // 4. Update chat metadata
      await chatRepository.updateChatMetadata(
        chatId: message.chatId,
        lastMessageId: remoteMessage.id,
      );
    } catch (e) {
      // 5. Mark as failed
      await local.updateMessageStatus(message.id, MessageStatus.failed);
    }
  }

  /// Retry all pending / failed messages
  Future<void> retryPendingMessages(GraphQLClient client) async {
    final pendingMessages = await _getRetryableMessages();

    for (final message in pendingMessages) {
      await sendMessage(client: client, message: message);
    }
  }

  /// Sync messages for a chat (server → local)
  Future<void> syncMessages(GraphQLClient client, String chatId) async {
    final remoteMessages = await remote.getMessages(chatId, client);
    Message? newest;

    for (final json in remoteMessages) {
      final remoteMessage = Message.fromJson(json);
      final localMessage = await local.findByRemoteId(remoteMessage.id);

      if (localMessage == null) {
        await local.saveMessage(remoteMessage);
      } else {
        final mergedStatus = mergeStatus(
          localMessage.status,
          remoteMessage.status,
        );

        await local.saveMessage(remoteMessage.copyWith(status: mergedStatus));
      }

      if (newest == null || remoteMessage.createdAt.isAfter(newest.createdAt)) {
        newest = remoteMessage;
      }
    }

    if (newest != null) {
      await chatRepository.updateChatMetadata(
        chatId: chatId,
        lastMessageId: newest.id,
      );
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(
    List<String> remoteIds,
    GraphQLClient client,
  ) async {
    if (remoteIds.isEmpty) return;

    await local.updateMessagesStatusByRemoteIds(remoteIds, MessageStatus.read);

    try {
      await remote.markMessagesAsRead(messagesIds: remoteIds, client: client);
    } catch (e) {
      throw Exception("$e");
    }
  }

  /// Apply subscription message (real-time)
  Future<void> applyIncomingMessage(Message incoming) async {
    // 0. Dedup by remoteId
    if (incoming.remoteId != null) {
      final existingByRemote = await local.findByRemoteId(incoming.remoteId!);

      if (existingByRemote != null) {
        await local.updateMessageStatus(
          existingByRemote.id,
          MessageStatus.sent,
        );

        await chatRepository.updateChatMetadata(
          chatId: incoming.chatId,
          lastMessageId: incoming.id,
        );
        return;
      }
    }

    // 1. Dedup by localTempId
    if (incoming.localTempId != null) {
      final existing = await local.findByLocalTempId(incoming.localTempId!);

      if (existing != null) {
        await local.updateAfterRemoteSync(
          localId: existing.id,
          remoteId: incoming.id,
        );

        await chatRepository.updateChatMetadata(
          chatId: incoming.chatId,
          lastMessageId: incoming.id,
        );
        return;
      }
    }

    // 2. New incoming message
    await local.saveMessage(incoming.copyWith(status: MessageStatus.sent));
    cacheMessage(incoming);

    await chatRepository.updateChatMetadata(
      chatId: incoming.chatId,
      lastMessageId: incoming.id,
    );
  }

  /// Subscribe to messages from local db
  Stream<List<Message>> watchMessages(String chatId) {
    return local.watchMessages(chatId);
  }

  Stream<Message?> watchLastMessageForChat(String chatId) {
    return local.watchLastMessageForChat(chatId);
  }

  final Map<String, StreamSubscription> _subscriptions = {};

  /// Subscribe to realtime messages for a chat
  void subscribeToChat({
    required GraphQLClient client,
    required String chatId,
  }) {
    if (_subscriptions.containsKey(chatId)) {
      return;
    }

    final sub = remote
        .subscribeNewMessages(chatId, client)
        .listen(
          (json) async {
            final message = Message.fromJson(json);
            await applyIncomingMessage(message);
          },
          onError: (e) {
            throw Exception(e);
          },
          onDone: () {},
        );

    _subscriptions[chatId] = sub;
  }

  /// Unsubscribe to realtime messages for a chat
  void unsubscribeFromChat(String chatId) {
    _subscriptions[chatId]?.cancel();
    _subscriptions.remove(chatId);
  }

  /// Return all pending / failed messages from local db
  Future<List<Message>> _getRetryableMessages() async {
    // simple solution, could be enhanced later
    final all = await local.db.select(local.db.messagesTable).get();

    return all
        .map((row) => row.toDomain())
        .where(
          (m) =>
              m.status == MessageStatus.pending ||
              m.status == MessageStatus.failed,
        )
        .toList();
  }
}
