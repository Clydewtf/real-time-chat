import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../data/repositories/message_repository.dart';
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
  late final ScrollController _scrollController;
  late final ProviderSubscription<AsyncValue<List<Message>>> _messagesSub;
  late final MessageRepository _repo;
  late final GraphQLClient _client;

  static const int _pageSize = 15;
  static const double _bottomThreshold = 150;
  static const double _topThreshold = 0;

  List<Message> _messages = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isNearBottom = true;

  DateTime? _oldestCursor;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(_initialLoad);

    _repo = ref.read(messageRepositoryProvider);
    _client = ref.read(dynamicGraphQLClientProvider);

    _repo.syncMessages(_client, widget.chatId);
    _repo.subscribeToChat(client: _client, chatId: widget.chatId);

    _messagesSub = ref.listenManual<AsyncValue<List<Message>>>(
      chatMessagesProvider(widget.chatId),
      (previous, next) {
        next.whenData((messages) {
          if (messages.isEmpty) return;

          final newest = messages.first;

          final pendingIndex = _messages.indexWhere(
            (m) => m.localTempId != null && m.localTempId == newest.localTempId,
          );

          if (pendingIndex != -1) {
            setState(() {
              _messages[pendingIndex] = newest;
            });
            return;
          }

          final exists = _messages.any((m) => m.id == newest.id);

          if (!exists) {
            setState(() {
              _messages.insert(0, newest);
            });

            if (_isNearBottom) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_scrollController.hasClients) return;

                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              });
            }
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _messagesSub.close();

    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    _repo.unsubscribeFromChat();

    controller.dispose();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    final repo = ref.read(messageRepositoryProvider);
    final latest = await repo.getLatestMessages(widget.chatId, _pageSize);

    if (!mounted) return;

    setState(() {
      _messages = latest;
      _oldestCursor = latest.isNotEmpty ? latest.last.createdAt : null;
      _hasMore = latest.length == _pageSize;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final isNearBottom = position.pixels <= _bottomThreshold;

    if (_isNearBottom != isNearBottom) {
      setState(() {
        _isNearBottom = isNearBottom;
      });
    }

    if (position.pixels >= position.maxScrollExtent - _topThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _oldestCursor == null) return;

    _isLoadingMore = true;
    final repo = ref.read(messageRepositoryProvider);

    final older = await repo.getOlderMessages(
      widget.chatId,
      _oldestCursor!,
      _pageSize,
    );

    if (!mounted) return;

    if (older.isEmpty) {
      _hasMore = false;
      _isLoadingMore = false;
      return;
    }

    setState(() {
      _messages.addAll(older);
      _oldestCursor = older.last.createdAt;
    });

    _hasMore = older.length == _pageSize;
    _isLoadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chat',
      centerTitle: true,
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: AppLoadingIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                    itemCount: _messages.length,
                    itemBuilder: (_, index) {
                      final msg = _messages[index];
                      final isMe = msg.senderId == widget.currentUserId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs / 2,
                        ),
                        child: MessageBubble(
                          text: msg.content,
                          type: isMe
                              ? BubbleType.outgoing
                              : BubbleType.incoming,
                          status: msg.status,
                        ),
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

              setState(() {
                _messages.insert(0, message);
              });

              await repo.sendMessage(client: client, message: message);
            },
          ),
        ],
      ),
    );
  }
}
