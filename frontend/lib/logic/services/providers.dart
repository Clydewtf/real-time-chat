import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../state/auth_notifier.dart';
import '../../core/utils/config.dart';


// Remote datasource provider
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource();
});

// Local datasource provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasource(AppDatabase());
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDatasourceProvider);
  final local = ref.watch(authLocalDatasourceProvider);
  return AuthRepository(remote: remote, local: local);
});

// Notifier provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
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