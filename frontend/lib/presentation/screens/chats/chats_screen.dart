import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../logic/services/providers.dart';
import '../../widgets/chat/chat_card.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_divider.dart';
import '../../widgets/common/app_loading_indicator.dart';
import '../../widgets/constants/app_spacing.dart';
import '../../widgets/layout/app_scaffold.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserIdAsync = ref.watch(currentUserIdProvider);

    return currentUserIdAsync.when(
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (currentUserId) {
        if (currentUserId == null) {
          return const Center(child: Text("Unauthorized"));
        }

        final chatAsync = ref.watch(userChatsProvider(currentUserId));

        return AppScaffold(
          showAppBar: false,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Column(
                  children: [
                    AppButton(
                      label: "Search users",
                      expanded: true,
                      outlined: true,
                      icon: Icons.search,
                      onPressed: () {
                        context.pushNamed('user_search');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: chatAsync.when(
                  loading: () => const Center(child: AppLoadingIndicator()),
                  error: (e, _) => Center(child: Text("Error: $e")),
                  data: (chats) {
                    if (chats.isEmpty) {
                      return const Center(child: Text("No chats yet"));
                    }

                    return ListView.separated(
                      itemCount: chats.length,
                      separatorBuilder: (_, __) => const AppDivider(),
                      itemBuilder: (_, index) {
                        final chat = chats[index];

                        final title =
                            chat.title ??
                            (chat.participantIds.length == 2
                                ? chat.participantIds.firstWhere(
                                    (id) => id != currentUserId,
                                  )
                                : "Group");

                        final lastMessageTime =
                            chat.updatedAt ?? chat.createdAt;
                        final formattedTime = DateFormat(
                          'HH:mm',
                        ).format(lastMessageTime);

                        return ChatCard(
                          name: title,
                          lastMessage: chat.lastMessageId ?? '',
                          time: formattedTime,
                          avatarUrl:
                              chat.avatarUrl ??
                              'https://i.pravatar.cc/150?img=${index + 1}',
                          onTap: () => context.pushNamed(
                            'chat_details',
                            pathParameters: {"id": chat.id},
                            extra: currentUserId,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
