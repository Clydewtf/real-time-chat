import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import '../state/auth_notifier.dart';
import '../../core/config.dart';


// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // final client = ref.watch(graphQLClientProvider);
  // return AuthRepository(client);
  return AuthRepository();
});

// Notifier
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
