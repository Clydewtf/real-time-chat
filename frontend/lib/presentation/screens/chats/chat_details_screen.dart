import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/datasources/local/drift/app_database.dart';
import '../../../data/datasources/local/message/message_local_datasource.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/value_objects/message_status.dart';
import '../../../domain/value_objects/message_type.dart';
import '../../../logic/services/providers.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input_bar.dart';
import '../../widgets/constants/app_spacing.dart';
import '../../widgets/layout/app_scaffold.dart';


class ChatDetailsScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatDetailsScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends ConsumerState<ChatDetailsScreen> {
  final controller = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messageLocal = ref.read(messageLocalDatasourceProvider);
    final msgs = await messageLocal.getMessages(widget.chatId);
    setState(() => messages = msgs);
  }

  Future<void> _sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final messageLocal = ref.read(messageLocalDatasourceProvider);

    final msg = Message(
      id: const Uuid().v4(),
      chatId: widget.chatId,
      senderId: "0a723c2c-052c-49ee-b1ad-5ee7660b52bb",
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
      title: 'Чат',
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final msg = messages[index];
                final isMe = msg.senderId == "0a723c2c-052c-49ee-b1ad-5ee7660b52bb";

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.content),
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


// class ChatDetailsScreen extends StatefulWidget {
//   final String chatId;

//   const ChatDetailsScreen({super.key, required this.chatId});

//   @override
//   State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
// }

// class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
//   final _controller = TextEditingController();

//   final messages = [
//     {'text': 'Hello!', 'type': BubbleType.incoming},
//     {'text': 'How are you?', 'type': BubbleType.incoming},
//     {'text': 'Fine, working on UI!', 'type': BubbleType.outgoing},
//   ];

//   void _handleSend() {
//     if (_controller.text.trim().isEmpty) return;
//     setState(() {
//       messages.add({'text': _controller.text.trim(), 'type': BubbleType.outgoing});
//     });
//     _controller.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       title: 'Chat ${widget.chatId}',
//       centerTitle: true,
//       padding: EdgeInsets.zero,
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(AppSpacing.m),
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final msg = messages[index];
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
//                   child: MessageBubble(
//                     text: msg['text'] as String,
//                     type: msg['type'] as BubbleType,
//                   ),
//                 );
//               },
//             ),
//           ),
//           MessageInputBar(
//             controller: _controller,
//             onSend: _handleSend,
//           ),
//         ],
//       ),
//     );
//   }
// }