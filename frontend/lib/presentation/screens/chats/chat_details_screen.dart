import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/value_objects/message_status.dart';
import '../../../domain/value_objects/message_type.dart';
import '../../../logic/services/providers.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input_bar.dart';
import '../../widgets/common/app_loading_indicator.dart';
import '../../widgets/constants/app_spacing.dart';
import '../../widgets/layout/app_scaffold.dart';

class ChatDetailsScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatDetailsScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  ConsumerState<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends ConsumerState<ChatDetailsScreen> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();

    final repo = ref.read(messageRepositoryProvider);
    final client = ref.read(dynamicGraphQLClientProvider);

    repo.syncMessages(client, widget.chatId);
    repo.subscribeToChat(client: client, chatId: widget.chatId);
  }

  @override
  void dispose() {
    ref.read(messageRepositoryProvider).unsubscribeFromChat();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));

    return AppScaffold(
      title: 'Chat',
      centerTitle: true,
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: AppLoadingIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUserId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs / 2,
                      ),
                      child: MessageBubble(
                        text: msg.content,
                        type: isMe ? BubbleType.outgoing : BubbleType.incoming,
                        status: msg.status,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          MessageInputBar(
            controller: controller,
            onSend: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              final repo = ref.read(messageRepositoryProvider);
              final client = ref.read(dynamicGraphQLClientProvider);

              final message = Message(
                id: const Uuid().v4(),
                chatId: widget.chatId,
                senderId: widget.currentUserId,
                content: text,
                createdAt: DateTime.now(),
                status: MessageStatus.pending,
                localTempId: const Uuid().v4(),
                type: MessageType.text,
              );

              controller.clear();

              await repo.sendMessage(client: client, message: message);
            },
          ),
        ],
      ),
    );
  }
}
