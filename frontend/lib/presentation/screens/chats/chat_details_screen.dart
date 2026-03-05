import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/widgets/chat/date_divider.dart';
import 'package:frontend/presentation/widgets/chat/scroll_to_bottom_button.dart';
import 'package:frontend/presentation/widgets/constants/app_radius.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/theme.dart';
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
  late final ProviderSubscription<AsyncValue<List<Message>>> _messagesSub;
  late final ItemScrollController _itemScrollController;
  late final ItemPositionsListener _itemPositionsListener;
  late final MessageRepository _repo;
  late final GraphQLClient _client;
  final Set<String> _pendingReadIds = {};

  static const int _pageSize = 15;

  int _unreadCount = 0;
  List<Message> _messages = [];
  bool _showScrollToBottom = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isNearBottom = true;
  bool _isMarkingRead = false;
  bool _showFloatingDate = false;

  DateTime? _oldestCursor;
  String? _floatingDate;
  Timer? _floatingDateTimer;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(_onPositionsChanged);

    _messages.clear();
    Future.microtask(_initialLoad);

    _repo = ref.read(messageRepositoryProvider);
    _client = ref.read(dynamicGraphQLClientProvider);

    _repo.syncMessages(_client, widget.chatId);
    _repo.subscribeToChat(client: _client, chatId: widget.chatId);

    _messagesSub = ref.listenManual<AsyncValue<List<Message>>>(
      chatMessagesProvider(widget.chatId),
      (previous, next) {
        next.whenData((messages) {
          if (!mounted || messages.isEmpty) return;

          bool updated = false;

          for (final msg in messages) {
            final pendingIndex = _messages.indexWhere(
              (m) => m.localTempId != null && m.localTempId == msg.localTempId,
            );
            if (pendingIndex != -1) {
              if (_pendingReadIds.contains(msg.id)) {
                continue;
              }
              _messages[pendingIndex] = msg;
              updated = true;
              continue;
            }

            final exists = _messages.any((m) => m.id == msg.id);
            if (!exists) {
              _messages.add(msg);
              updated = true;

              if (!_isNearBottom) {
                _unreadCount++;
              } else if (msg.senderId != widget.currentUserId) {
                _markVisibleMessagesAsRead();
              }
            }
          }

          if (updated) {
            _messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            setState(() {});

            if (_isNearBottom) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_itemScrollController.isAttached) return;

                _itemScrollController.jumpTo(index: 0);
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

    _floatingDateTimer?.cancel();

    _repo.unsubscribeFromChat();

    controller.dispose();
    _itemPositionsListener.itemPositions.removeListener(_onPositionsChanged);
    super.dispose();
  }

  void _onPositionsChanged() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty || _messages.isEmpty) return;

    final minIndex = positions
        .where((p) => p.itemTrailingEdge > 0)
        .map((p) => p.index)
        .reduce((a, b) => a < b ? a : b);

    final isNearBottom = minIndex <= 1;

    if (_isNearBottom != isNearBottom) {
      setState(() {
        _isNearBottom = isNearBottom;
        _showScrollToBottom = !isNearBottom;

        if (isNearBottom) {
          _markVisibleMessagesAsRead();
        }
      });
    }

    if (positions.isEmpty || _messages.isEmpty) return;

    final topIndex = positions
        .map((p) => p.index)
        .reduce((a, b) => a > b ? a : b);

    if (topIndex >= 0 && topIndex < _messages.length) {
      final message = _messages[topIndex];
      final formatted = formatDateSeparator(message.createdAt);

      if (_floatingDate != formatted) {
        setState(() {
          _floatingDate = formatted;
          _showFloatingDate = true;
        });
      }

      _floatingDateTimer?.cancel();
      _floatingDateTimer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _showFloatingDate = false;
          });
        }
      });
    }

    final maxIndex = positions
        .map((e) => e.index)
        .reduce((a, b) => a > b ? a : b);

    if (maxIndex >= _messages.length - 3) {
      _loadMore();
    }
  }

  Future<void> _initialLoad() async {
    final repo = ref.read(messageRepositoryProvider);
    final latest = await repo.getLatestMessages(widget.chatId, _pageSize);

    // final db = ref.read(appDatabaseProvider);
    // final rows = await db.select(db.messagesTable).get();
    // for (final row in rows) {
    //   print('${row.id} | ${row.status} | ${row.content} | ${row.createdAt}');
    // }

    if (!mounted) return;

    setState(() {
      _messages = latest;
      _oldestCursor = latest.isNotEmpty ? latest.last.createdAt : null;
      _hasMore = latest.length == _pageSize;
    });

    final unreadIncomingIds = _messages
        .where(
          (m) =>
              m.senderId != widget.currentUserId &&
              m.status != MessageStatus.read &&
              m.remoteId != null,
        )
        .map((m) => m.remoteId!)
        .toList();

    if (unreadIncomingIds.isNotEmpty) {
      await _repo.markMessagesAsRead(unreadIncomingIds);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemScrollController.isAttached) {
        _itemScrollController.jumpTo(index: 0);
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _oldestCursor == null) return;

    _isLoadingMore = true;

    final older = await _repo.getOlderMessages(
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

    final existingIds = _messages.map((m) => m.id).toSet();
    final uniqueOlder = older
        .where((m) => !existingIds.contains(m.id))
        .toList();

    if (uniqueOlder.isEmpty) {
      _hasMore = false;
      _isLoadingMore = false;
      return;
    }

    setState(() {
      _messages.addAll(uniqueOlder);
      _oldestCursor = uniqueOlder.last.createdAt;
    });

    _hasMore = uniqueOlder.length == _pageSize;
    _isLoadingMore = false;
  }

  Future<void> _markVisibleMessagesAsRead() async {
    if (_isMarkingRead) return;

    final unreadIncoming = _messages.where(
      (m) =>
          m.senderId != widget.currentUserId && m.status != MessageStatus.read,
    );
    final remoteIds = unreadIncoming
        .where((m) => m.remoteId != null)
        .map((m) => m.remoteId!)
        .toList();

    if (remoteIds.isEmpty) return;

    _isMarkingRead = true;

    setState(() {
      for (final id in remoteIds) {
        final index = _messages.indexWhere((m) => m.id == id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(
            status: MessageStatus.read,
          );
        }
      }

      _unreadCount = 0;
    });

    _pendingReadIds.addAll(remoteIds);

    try {
      await _repo.markMessagesAsRead(remoteIds);
    } catch (e) {
      throw Exception("$e");
    } finally {
      _pendingReadIds.removeAll(remoteIds);
      _isMarkingRead = false;
    }
  }

  void _scrollToBottom() {
    if (!_itemScrollController.isAttached) return;

    _itemScrollController.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    setState(() {
      _unreadCount = 0;
    });
  }

  bool shouldInsertTimeGap(DateTime current, DateTime? older) {
    if (older == null) return false;

    final difference = current.difference(older).inMinutes;
    return difference >= 10;
  }

  bool isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();

    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  bool shouldInsertDayDivider(DateTime current, DateTime? older) {
    if (older == null) return true;

    return !isSameDay(current, older);
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
            child: Stack(
              children: [
                _messages.isEmpty
                    ? const Center(child: AppLoadingIndicator())
                    : ScrollablePositionedList.builder(
                        itemScrollController: _itemScrollController,
                        itemPositionsListener: _itemPositionsListener,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.m,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (_, index) {
                          final msg = _messages[index];
                          final isMe = msg.senderId == widget.currentUserId;

                          final older = index < _messages.length - 1
                              ? _messages[index + 1]
                              : null;
                          final showGap = shouldInsertTimeGap(
                            msg.createdAt,
                            older?.createdAt,
                          );
                          final showDateDivider = shouldInsertDayDivider(
                            msg.createdAt,
                            older?.createdAt,
                          );

                          return Column(
                            children: [
                              if (showDateDivider)
                                DateDivider(
                                  text: formatDateSeparator(msg.createdAt),
                                ),

                              Padding(
                                padding: EdgeInsets.only(
                                  top: showGap
                                      ? AppSpacing.s
                                      : AppSpacing.xs / 2,
                                  bottom: AppSpacing.xs / 2,
                                ),
                                child: MessageBubble(
                                  text: msg.content,
                                  type: isMe
                                      ? BubbleType.outgoing
                                      : BubbleType.incoming,
                                  status: msg.status,
                                  timestamp: msg.createdAt,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                if (_showFloatingDate && _floatingDate != null)
                  Positioned(
                    top: AppSpacing.m,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: _showFloatingDate ? 1 : 0,
                      duration: Duration(milliseconds: 200),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightOnSurface.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppRadius.m * 2,
                            ),
                          ),
                          child: Text(
                            _floatingDate!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.lightOnSurface.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (_showScrollToBottom)
                  Positioned(
                    right: AppSpacing.m,
                    bottom: AppSpacing.m,
                    child: ScrollToBottomButton(
                      unreadCount: _unreadCount,
                      onPressed: _scrollToBottom,
                    ),
                  ),
              ],
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
