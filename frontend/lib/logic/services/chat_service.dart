import 'package:graphql_flutter/graphql_flutter.dart';
import '../../data/datasources/local/chat/chat_local_datasource.dart';
import '../../data/datasources/local/message/message_local_datasource.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/entities/chat.dart';
import 'package:uuid/uuid.dart';


class ChatService {
  final ChatLocalDatasource chatLocal;
  final MessageLocalDatasource messageLocal;
  final UserRepository userRepository;

  final uuid = const Uuid();

  ChatService({
    required this.chatLocal,
    required this.messageLocal,
    required this.userRepository,
  });

  /// Create new private chat between currentUser and another user by username
  Future<String?> createOrGetPrivateChat({
    required GraphQLClient client,
    required String currentUserId,
    required String username,
  }) async {
    final users = await userRepository.searchUsers(client, username);
    if (users.isEmpty) throw Exception('User not found');

    final otherUser = users.first;
    if (otherUser.id == currentUserId) return null;

    Chat? chat = await chatLocal.findDirectChat(currentUserId, otherUser.id);

    if (chat == null) {
      final newChatId = uuid.v4();
      chat = Chat(
        id: newChatId,
        participantIds: [currentUserId, otherUser.id],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await chatLocal.saveChat(chat);
    }

    return chat.id;
  }
}