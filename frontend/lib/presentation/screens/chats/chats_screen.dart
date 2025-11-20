import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/chat.dart';
import '../../../logic/services/providers.dart';
import '../../widgets/chat/chat_card.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_divider.dart';
import '../../widgets/common/app_loading_indicator.dart';
import '../../widgets/constants/app_spacing.dart';
import '../../widgets/layout/app_scaffold.dart';


class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  List<Chat> chats = [];

  Future<void> _loadChats(String currentUserId) async {
    final chatLocal = ref.read(chatLocalDatasourceProvider);
    final list = await chatLocal.getUserChats(currentUserId);
    setState(() => chats = list);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserIdAsync = ref.watch(currentUserIdProvider);

    return currentUserIdAsync.when(
      data: (currentUserId) {
        if (currentUserId == null) return const Center(child: Text("Unauthorized"));

        if (chats.isEmpty) _loadChats(currentUserId);

        return AppScaffold(
          showAppBar: false,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Chats',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    AppButton(
                      label: "Search users",
                      onPressed: () {
                        context.pushNamed('user_search');
                      },
                      expanded: true,
                      outlined: true,
                      icon: Icons.search,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Expanded(
                child: ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const AppDivider(),
                  itemBuilder: (_, index) {
                    final chat = chats[index];
                    final title = chat.title ??
                        (chat.participantIds.length == 2
                            ? chat.participantIds.firstWhere((id) => id != currentUserId)
                            : "Group");
                    final lastMessageTime = chat.updatedAt ?? chat.createdAt;
                    final formattedTime = DateFormat('HH:mm').format(lastMessageTime);

                    return ChatCard(
                      name: title,
                      lastMessage: chat.lastMessageId ?? '',
                      time: formattedTime,
                      avatarUrl: chat.avatarUrl ?? 'https://i.pravatar.cc/150?img=${index + 1}',
                      onTap: () => context.pushNamed(
                        "chat_details",
                        pathParameters: {"id": chat.id},
                        extra: currentUserId,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (e, st) => Center(child: Text("Error: $e")),
    );
  }
}