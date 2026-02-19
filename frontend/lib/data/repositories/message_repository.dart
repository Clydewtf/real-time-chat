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

  StreamSubscription<Map<String, dynamic>>? _subscription;

  MessageRepository({
    required this.local,
    required this.remote,
    required this.chatRepository,
  });

  /// OFFLINE-FIRST send message
  Future<void> sendMessage({
    required GraphQLClient client,
    required Message message,
  }) async {
    // 1. Save locally as pending
    await local.saveMessage(message.copyWith(status: MessageStatus.pending));

    try {
      // 2. Send remotely
      final remoteJson = await remote.sendMessage(
        client: client,
        chatId: message.chatId,
        content: message.content,
        localTempId: message.localTempId ?? message.id,
      );

      final remoteMessage = Message.fromJson(remoteJson);

      // 3. Update local message after sync
      await local.updateAfterRemoteSync(
        localId: message.id,
        remoteId: remoteMessage.id,
      );

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
    final remoteMessages = await remote.getMessages(client, chatId);

    for (final json in remoteMessages) {
      final message = Message.fromJson(json);

      final existing = await local.findByRemoteId(message.id);
      if (existing != null) continue;

      await local.saveMessage(message.copyWith(status: MessageStatus.sent));

      await chatRepository.updateChatMetadata(
        chatId: chatId,
        lastMessageId: message.id,
      );
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

    await chatRepository.updateChatMetadata(
      chatId: incoming.chatId,
      lastMessageId: incoming.id,
    );
  }

  /// Subscribe to messages from local db
  Stream<List<Message>> watchMessages(String chatId) {
    return local.watchMessages(chatId);
  }

  /// Subscribe to realtime messages for a chat
  void subscribeToChat({
    required GraphQLClient client,
    required String chatId,
  }) {
    _subscription?.cancel();

    _subscription = remote.subscribeNewMessages(client, chatId).listen((
      json,
    ) async {
      final message = Message.fromJson(json);
      await applyIncomingMessage(message);
    });
  }

  /// Unsubscribe to realtime messages for a chat
  void unsubscribeFromChat() {
    _subscription?.cancel();
    _subscription = null;
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
