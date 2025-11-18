import 'package:flutter/material.dart';
import '../../../logic/services/chat_service.dart';


class CreateChatScreen extends StatefulWidget {
  final ChatService chatService;
  final String currentUserId;

  const CreateChatScreen({
    super.key,
    required this.chatService,
    required this.currentUserId,
  });

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final emailCtrl = TextEditingController();
  final msgCtrl = TextEditingController();

  bool loading = false;

  Future<void> _handleCreate() async {
    if (loading) return;
    setState(() => loading = true);

    final chatId = await widget.chatService.sendMessageToEmail(
      email: emailCtrl.text.trim(),
      text: msgCtrl.text.trim(),
      currentUserId: widget.currentUserId,
    );

    setState(() => loading = false);

    if (chatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
      return;
    }

    Navigator.pop(context, chatId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create chat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'User Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              decoration: const InputDecoration(labelText: 'First message'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleCreate,
              child: loading ? const CircularProgressIndicator() : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}