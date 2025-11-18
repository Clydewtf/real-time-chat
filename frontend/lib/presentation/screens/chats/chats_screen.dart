import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local/chat/chat_local_datasource.dart';
import '../../../data/datasources/local/drift/app_database.dart';
import '../../../domain/entities/chat.dart';
import '../../../logic/services/chat_service.dart';
import '../../../logic/services/providers.dart';
import '../../widgets/chat/chat_card.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/app_divider.dart';
import '../../widgets/constants/app_spacing.dart';
import '../../widgets/layout/app_scaffold.dart';
import 'create_chat_screen.dart';


class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  List<Chat> chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final chatLocal = ref.read(chatLocalDatasourceProvider);
    const currentUserId = "0a723c2c-052c-49ee-b1ad-5ee7660b52bb";

    final list = await chatLocal.getUserChats(currentUserId);
    setState(() => chats = list);
  }

  Future<void> _handleNewChat() async {
    final chatId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateChatScreen(
          chatService: ref.read(chatServiceProvider),
          currentUserId: "0a723c2c-052c-49ee-b1ad-5ee7660b52bb",
        ),
      ),
    );

    if (chatId != null) _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Чаты',
      floatingActionButton: FloatingActionButton(
        onPressed: _handleNewChat,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (_, index) {
          final chat = chats[index];

          return ListTile(
            title: Text(chat.title ?? 'Чат'),
            subtitle: Text('Участники: ${chat.participantIds.length}'),
            onTap: () {
              context.pushNamed(
                'chat_details',
                pathParameters: {'id': chat.id},
              );
            },
          );
        },
      ),
    );
  }
}


// class ChatsScreen extends StatelessWidget {
//   const ChatsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final chats = List.generate(10, (index) => 'Chat ${index + 1}');

//     return AppScaffold(
//       showAppBar: false,
//       body: ListView.separated(
//         itemCount: chats.length,
//         separatorBuilder: (_, __) => const AppDivider(),
//         itemBuilder: (context, index) {
//           final name = chats[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
//             child: ChatCard(
//               name: name,
//               lastMessage: 'Last message...',
//               time: '10:${index}0',
//               avatarUrl: 'https://i.pravatar.cc/150?img=${index + 1}',
//               onTap: () => context.pushNamed('chat_details', pathParameters: {'id': '$index'},),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }