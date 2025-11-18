import '../../data/datasources/local/chat/chat_local_datasource.dart';
import '../../data/datasources/local/message/message_local_datasource.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/value_objects/message_status.dart';
import '../../domain/value_objects/message_type.dart';
import 'user_search_service.dart';
import 'package:uuid/uuid.dart';


class ChatService {
  final ChatLocalDatasource chatLocal;
  final MessageLocalDatasource messageLocal;
  final UserSearchService userSearch;

  final uuid = const Uuid();

  ChatService({
    required this.chatLocal,
    required this.messageLocal,
    required this.userSearch,
  });

  Future<String?> sendMessageToEmail({
    required String email,
    required String text,
    required String currentUserId,
  }) async {
    final otherUserId = await userSearch.findUserIdByEmail(email);
    if (otherUserId == null) return null;

    // 1. Проверяем, есть ли чат
    Chat? chat = await chatLocal.findDirectChat(currentUserId, otherUserId);

    // 2. Если чата нет — создаём
    if (chat == null) {
      final newChatId = uuid.v4();
      chat = Chat(
        id: newChatId,
        participantIds: [currentUserId, otherUserId],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await chatLocal.saveChat(chat);
    }

    // 3. Создаём сообщение
    final msg = Message(
      id: uuid.v4(),
      chatId: chat.id,
      senderId: currentUserId,
      content: text,
      createdAt: DateTime.now(),
      status: MessageStatus.pending,
      type: MessageType.text,
    );

    await messageLocal.saveMessage(msg);

    // 4. обновляем lastMessageId
    await chatLocal.updateLastMessageId(chat.id, msg.id);

    return chat.id;
  }
}