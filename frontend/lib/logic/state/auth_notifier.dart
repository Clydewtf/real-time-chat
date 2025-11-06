import 'package:flutter_riverpod/legacy.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../data/repositories/auth_repository.dart';


class AuthState {
  final bool isLoading;
  final String? token;
  final String? error;

  AuthState({this.isLoading = false, this.token, this.error});

  AuthState copyWith({bool? isLoading, String? token, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthState());

  Future<void> login(String email, String password, GraphQLClient client) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await repository.login(client, email, password);
      if (res['success'] == true) {
        state = state.copyWith(isLoading: false, token: res['token']);
      } else {
        state = state.copyWith(isLoading: false, error: res['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String email, String password, GraphQLClient client) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await repository.register(client, email, password);
      if (res['success'] == true) {
        state = state.copyWith(isLoading: false, token: res['token']);
      } else {
        state = state.copyWith(isLoading: false, error: res['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}