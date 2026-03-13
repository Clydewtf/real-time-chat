import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/data/datasources/remote/chat/chat_remote_datasource.dart';
import 'package:frontend/data/datasources/remote/message/message_remote_datasource.dart';
import 'package:frontend/data/repositories/chat_repository.dart';
import 'package:frontend/data/repositories/message_repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../data/datasources/local/auth/auth_local_datasource.dart';
import '../../data/datasources/local/chat/chat_local_datasource.dart';
import '../../data/datasources/local/drift/app_database.dart';
import '../../data/datasources/local/message/message_local_datasource.dart';
import '../../data/datasources/remote/auth/auth_remote_datasource.dart';
import '../../data/datasources/remote/user/user_remote_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../state/auth_notifier.dart';
import '../../core/utils/config.dart';
import '../services/connection_service.dart';

// Drift database provider
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// Remote datasource providers
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource();
});

final userRemoteDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  final client = ref.watch(graphQLHttpClientProvider);
  return UserRemoteDatasource(client);
});

final chatRemoteDatasourceProvider = Provider<ChatRemoteDatasource>((ref) {
  return ChatRemoteDatasource();
});

final messageRemoteDatasourceProvider = Provider<MessageRemoteDatasource>((
  ref,
) {
  //final client = ref.watch(dynamicGraphQLClientProvider);
  return MessageRemoteDatasource();
});

// Local datasource providers
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasource(ref.read(appDatabaseProvider));
});

final chatLocalDatasourceProvider = Provider<ChatLocalDatasource>((ref) {
  return ChatLocalDatasource(ref.read(appDatabaseProvider));
});

final messageLocalDatasourceProvider = Provider<MessageLocalDatasource>((ref) {
  return MessageLocalDatasource(ref.read(appDatabaseProvider));
});

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDatasourceProvider);
  final local = ref.watch(authLocalDatasourceProvider);
  return AuthRepository(remote: remote, local: local);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remote = ref.read(userRemoteDatasourceProvider);
  return UserRepository(remote: remote);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    local: ref.read(chatLocalDatasourceProvider),
    remote: ref.read(chatRemoteDatasourceProvider),
    userRepository: ref.read(userRepositoryProvider),
  );
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(
    local: ref.read(messageLocalDatasourceProvider),
    remote: ref.read(messageRemoteDatasourceProvider),
    chatRepository: ref.read(chatRepositoryProvider),
  );
});

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final repo = ref.read(authRepositoryProvider);
  return repo.getCurrentUserId();
});

// Notifier providers
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

// Stream providers
final userChatsProvider = StreamProvider.family<List<Chat>, String>((
  ref,
  userId,
) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchChatsForUser(userId);
});

final chatMessagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  chatId,
) {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.watchMessages(chatId);
});

final lastMessageProvider = StreamProvider.family<Message?, String>((
  ref,
  chatId,
) {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.watchLastMessageForChat(chatId);
});

// GraphQLClient provider
final dynamicGraphQLClientProvider = Provider<GraphQLClient>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final token = authState.token;

  print('>>> Creating GraphQLClient, token = $token');

  final httpLink = HttpLink(
    AppConfig.graphqlEndpoint,
    defaultHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
  );

  final websocketLink = WebSocketLink(
    AppConfig.graphqlWsEndpoint,
    config: SocketClientConfig(
      autoReconnect: true,
      initialPayload: () => {
        'headers': token != null ? {'Authorization': 'Bearer $token'} : {},
      },
    ),
  );

  final link = Link.split(
    (request) => request.isSubscription,
    websocketLink,
    httpLink,
  );

  return GraphQLClient(cache: GraphQLCache(), link: link);
});

final graphQLHttpClientProvider = Provider<GraphQLClient>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final token = authState.token;

  final httpLink = HttpLink(
    AppConfig.graphqlEndpoint,
    defaultHeaders: {if (token != null) 'Authorization': 'Bearer $token'},
  );

  return GraphQLClient(cache: GraphQLCache(), link: httpLink);
});

// GraphQL client with explicit token provider (for sync / background)
final graphQLClientWithTokenProvider = Provider.family<GraphQLClient, String>((
  ref,
  token,
) {
  final httpLink = HttpLink(
    AppConfig.graphqlEndpoint,
    defaultHeaders: {'Authorization': 'Bearer $token'},
  );

  final websocketLink = WebSocketLink(
    AppConfig.graphqlWsEndpoint,
    config: SocketClientConfig(
      autoReconnect: true,
      initialPayload: () => {
        'headers': {'Authorization': 'Bearer $token'},
      },
    ),
  );

  final link = Link.split(
    (request) => request.isSubscription,
    websocketLink,
    httpLink,
  );

  return GraphQLClient(cache: GraphQLCache(), link: link);
});

// Sync listener provider
final authSyncListenerProvider = Provider<void>((ref) {
  ref.listen<AuthState>(authNotifierProvider, (prev, next) async {
    if (prev?.token == null && next.token != null) {
      final token = next.token!;
      final client = ref.read(graphQLClientWithTokenProvider(token));

      final authRepo = ref.read(authRepositoryProvider);
      final chatRepo = ref.read(chatRepositoryProvider);
      final messageRepo = ref.read(messageRepositoryProvider);

      final userId = await authRepo.getCurrentUserId();
      if (userId == null) return;

      try {
        await chatRepo.syncChats(client, userId, messageRepo);
        ref.invalidate(userChatsProvider(userId));

        await messageRepo.retryPendingMessages(client);
      } catch (e, st) {
        debugPrintStack(stackTrace: st);
      }
    }
  });
});

// Connectivity provider
final connectionStateProvider = StreamProvider<AppConnectionState>((
  ref,
) async* {
  final connectivity = Connectivity();

  Future<AppConnectionState> checkConnection() async {
    final results = await connectivity.checkConnectivity();
    final hasNetwork =
        !(results.length == 1 && results.contains(ConnectivityResult.none));

    if (!hasNetwork) {
      return AppConnectionState.offline;
    }

    final client = ref.read(dynamicGraphQLClientProvider);
    await Future.delayed(const Duration(milliseconds: 300));
    final reachable = await pingGraphQL(client);

    return reachable ? AppConnectionState.online : AppConnectionState.offline;
  }

  yield AppConnectionState.connecting;
  yield await checkConnection();

  await for (final results in connectivity.onConnectivityChanged) {
    final hasNetwork =
        !(results.length == 1 && results.contains(ConnectivityResult.none));

    if (!hasNetwork) {
      yield AppConnectionState.offline;
      continue;
    }

    yield AppConnectionState.connecting;

    final client = ref.read(dynamicGraphQLClientProvider);
    await Future.delayed(const Duration(milliseconds: 300));
    final reachable = await pingGraphQL(client);

    yield reachable ? AppConnectionState.online : AppConnectionState.offline;
  }
});
