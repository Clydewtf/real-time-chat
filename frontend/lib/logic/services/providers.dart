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


// Drift database provider
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// Remote datasource providers
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource();
});

final userRemoteDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  return UserRemoteDatasource();
});

final chatRemoteDatasourceProvider = Provider<ChatRemoteDatasource>((ref) {
  return ChatRemoteDatasource();
});

final messageRemoteDatasourceProvider = Provider<MessageRemoteDatasource>((ref) {
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
    local: ref.watch(chatLocalDatasourceProvider),
    remote: ref.watch(chatRemoteDatasourceProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(
    local: ref.watch(messageLocalDatasourceProvider),
    remote: ref.watch(messageRemoteDatasourceProvider),
    chatRepository: ref.watch(chatRepositoryProvider),
  );
});

// Service providers
// final chatServiceProvider = Provider<ChatService>((ref) {
//   final chatLocal = ref.watch(chatLocalDatasourceProvider);
//   final messageLocal = ref.watch(messageLocalDatasourceProvider);
//   final userRepo = ref.watch(userRepositoryProvider);
//   return ChatService(chatLocal: chatLocal, messageLocal: messageLocal, userRepository: userRepo);
// });

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final repo = ref.read(authRepositoryProvider);
  return repo.getCurrentUserId();
});

// Notifier providers
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

// Stream providers
final userChatsProvider = StreamProvider.family<List<Chat>, String>((ref, userId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchChatsForUser(userId);
});

final chatMessagesProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.watchMessages(chatId);
});

// GraphQLClient Provider
final dynamicGraphQLClientProvider = Provider<GraphQLClient>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final token = authState.token;

  final httpLink = HttpLink(
    AppConfig.graphqlEndpoint,
    defaultHeaders: token != null
        ? {'Authorization': 'Bearer $token'}
        : {},
  );

  return GraphQLClient(
    cache: GraphQLCache(),
    link: httpLink,
  );
});