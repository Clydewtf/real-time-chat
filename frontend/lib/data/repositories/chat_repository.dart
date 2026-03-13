import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/entities/chat.dart';
import '../datasources/local/chat/chat_local_datasource.dart';
import '../datasources/remote/chat/chat_remote_datasource.dart';
import 'message_repository.dart';
import 'user_repository.dart';

class ChatRepository {
  final ChatLocalDatasource local;
  final ChatRemoteDatasource remote;
  final UserRepository userRepository;

  ChatRepository({
    required this.local,
    required this.remote,
    required this.userRepository,
  });

  /// Offline-first: always return local chat id
  Future<String?> createOrGetPrivateChat({
    required GraphQLClient client,
    required String currentUserId,
    required String username,
  }) async {
    // 1. Find user
    final users = await userRepository.searchUsers(username);
    if (users.isEmpty) return null;

    final otherUser = users.first;
    if (otherUser.id == currentUserId) return null;

    // 2. Try local first
    final localChat = await local.findDirectChat(currentUserId, otherUser.id);
    if (localChat != null) return localChat.id;

    // 3. Create remote chat
    final chatJson = await remote.createPrivateChat(
      client: client,
      userA: currentUserId,
      userB: otherUser.id,
    );

    // 4. Convert to domain entity
    final chat = _fromRemote(chatJson);

    // 5. Save locally
    await local.saveChat(chat);

    return chat.id;
  }

  /// Subscribe to chats from local db
  Stream<List<Chat>> watchChatsForUser(String userId) {
    return local.watchUserChats(userId);
  }

  /// Sync all chats for current user from remote
  Future<void> syncChats(
    GraphQLClient client,
    String userId,
    MessageRepository messageRepo,
  ) async {
    final remoteChatsJson = await remote.getChatsForUser(client, userId);

    for (final chatJson in remoteChatsJson) {
      final chat = _fromRemote(chatJson);
      await local.saveChat(chat);

      final lastMessageId = chat.lastMessageId;
      if (lastMessageId == null) continue;

      final existing = await messageRepo.local.findByRemoteId(lastMessageId);

      if (existing != null) {
        messageRepo.cacheMessage(existing);
      } else {
        final message = await messageRepo.getMessageById(lastMessageId);

        if (message != null) {
          await messageRepo.local.saveMessage(message);
          messageRepo.cacheMessage(message);
        }
      }
    }
  }

  /// Update chat metadata on new incoming message
  Future<void> updateChatMetadata({
    required String chatId,
    required String lastMessageId,
    DateTime? updatedAt,
  }) async {
    // now only updating last message id
    await local.updateLastMessageId(chatId, lastMessageId);
  }

  /// Return opponent username from chat
  Future<String> getOpponentUsername(Chat chat, String currentUserId) async {
    if (chat.participantIds.length != 2) return '';

    final opponentId = chat.participantIds.firstWhere(
      (id) => id != currentUserId,
    );

    if (_usernameCache.containsKey(opponentId)) {
      return _usernameCache[opponentId]!;
    }

    final user = await userRepository.getUser(opponentId);
    final username = user?.username ?? '';
    _usernameCache[opponentId] = username;

    return username;
  }

  final Map<String, String> _usernameCache = {};

  String getCachedOpponentUsername(Chat chat, String currentUserId) {
    if (chat.participantIds.length != 2) return '';
    final opponentId = chat.participantIds.firstWhere(
      (id) => id != currentUserId,
    );
    return _usernameCache[opponentId] ?? '';
  }

  /// Convert GraphQL JSON -> domain Chat
  Chat _fromRemote(Map<String, dynamic> json) {
    final participants = (json['chat_participants'] as List)
        .map((e) => e['user_id'] as String)
        .toList();

    return Chat(
      id: json['id'] as String,
      type: json['type'] as String?,
      title: json['title'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      description: json['description'] as String?,
      participantIds: participants,
      lastMessageId: json['last_message_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
    );
  }
}
