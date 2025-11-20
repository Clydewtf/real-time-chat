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

  const ChatDetailsScreen({super.key, required this.chatId, required this.currentUserId});

  @override
  ConsumerState<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends ConsumerState<ChatDetailsScreen> {
  final controller = TextEditingController();
  List<Message> messages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => loading = true);

    final messageLocal = ref.read(messageLocalDatasourceProvider);
    final msgs = await messageLocal.getMessages(widget.chatId);
    if (!mounted) return;

    setState(() {
      messages = msgs;
      loading = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final messageLocal = ref.read(messageLocalDatasourceProvider);

    final msg = Message(
      id: const Uuid().v4(),
      chatId: widget.chatId,
      senderId: widget.currentUserId,
      content: text,
      createdAt: DateTime.now(),
      status: MessageStatus.pending,
      type: MessageType.text,
    );

    await messageLocal.saveMessage(msg);

    controller.clear();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chat &',
      body: loading
          ? const Center(child: AppLoadingIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == widget.currentUserId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                        child: MessageBubble(
                          text: msg.content,
                          type: isMe ? BubbleType.outgoing : BubbleType.incoming,
                        ),
                      );
                    },
                  ),
                ),
                MessageInputBar(
                  controller: controller,
                  onSend: _sendMessage,
                ),
              ],
            ),
    );
  }
}