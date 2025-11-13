import 'package:flutter/material.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input_bar.dart';
import '../../widgets/constants/app_spacing.dart';
import '../../widgets/layout/app_scaffold.dart';


class ChatDetailsScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailsScreen({super.key, required this.chatId});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final _controller = TextEditingController();

  final messages = [
    {'text': 'Hello!', 'type': BubbleType.incoming},
    {'text': 'How are you?', 'type': BubbleType.incoming},
    {'text': 'Fine, working on UI!', 'type': BubbleType.outgoing},
  ];

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      messages.add({'text': _controller.text.trim(), 'type': BubbleType.outgoing});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chat ${widget.chatId}',
      centerTitle: true,
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: MessageBubble(
                    text: msg['text'] as String,
                    type: msg['type'] as BubbleType,
                  ),
                );
              },
            ),
          ),
          MessageInputBar(
            controller: _controller,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}