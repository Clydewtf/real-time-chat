import 'package:flutter/material.dart';
import '../../widgets/chat/chat_card.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/app_divider.dart';
import '../../widgets/constants/app_spacing.dart';
import '../../widgets/layout/app_scaffold.dart';


class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = List.generate(10, (index) => 'Chat ${index + 1}');

    return AppScaffold(
      showAppBar: false,
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (_, __) => const AppDivider(),
        itemBuilder: (context, index) {
          final name = chats[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: ChatCard(
              name: name,
              lastMessage: 'Last message...',
              time: '10:${index}0',
              avatarUrl: 'https://i.pravatar.cc/150?img=${index + 1}',
              onTap: () => context.pushNamed('chat_details', pathParameters: {'id': '$index'},),
            ),
          );
        },
      ),
    );
  }
}