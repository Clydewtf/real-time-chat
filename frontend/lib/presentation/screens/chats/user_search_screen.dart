import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/dtos/user_dto.dart';
import '../../../logic/services/providers.dart';
import '../../widgets/chat/chat_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_divider.dart';
import '../../widgets/common/app_loading_indicator.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/constants/app_spacing.dart';
import '../../widgets/layout/app_scaffold.dart';


class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  List<UserDto> results = [];
  bool loading = false;

  void _onChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(text.trim());
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => results = []);
      return;
    }

    setState(() => loading = true);

    final repo = ref.read(userRepositoryProvider);
    final client = ref.read(dynamicGraphQLClientProvider);

    try {
      final found = await repo.searchUsers(client, query);
      setState(() => results = found);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _openChat(UserDto user) async {
    final currentUserIdAsync = ref.read(currentUserIdProvider);
    final currentUserId = currentUserIdAsync.maybeWhen(
      data: (id) => id,
      orElse: () => null,
    );
    if (currentUserId == null) return;

    final chatService = ref.read(chatServiceProvider);
    final client = ref.read(dynamicGraphQLClientProvider);

    final chatId = await chatService.createOrGetPrivateChat(
      client: client,
      currentUserId: currentUserId,
      username: user.username,
    );

    if (!mounted || chatId == null) return;

    context.pop();
    context.pushNamed(
      "chat_details",
      pathParameters: {"id": chatId},
      extra: currentUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _controller,
                    hintText: "User search",
                    onChanged: _onChanged,
                    autoFocus: true,
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              _onChanged('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                AppButton(
                  label: "Cancel",
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: AppLoadingIndicator())
                : results.isEmpty
                    ? const Center(child: Text("Nothing found"))
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const AppDivider(),
                        itemBuilder: (_, index) {
                          final user = results[index];
                          return ChatCard(
                            name: user.username,
                            avatarUrl: user.avatarUrl ?? '',
                            lastMessage: '',
                            time: '',
                            onTap: () => _openChat(user),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}