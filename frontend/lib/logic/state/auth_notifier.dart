import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../data/repositories/auth_repository.dart';


class AuthState {
  final bool isLoading;
  final bool isInitialized;
  final String? token;
  final String? error;

  AuthState({this.isLoading = false, this.isInitialized = false, this.token, this.error});

  AuthState copyWith({bool? isLoading, bool? isInitialized, String? token, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      token: token ?? this.token,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final _controller = StreamController<void>.broadcast();

  Stream<void> get changes => _controller.stream;

  AuthNotifier(this.repository) : super(AuthState()) {
    init();
  }

  // Future<void> init() async {
  //   final token = await repository.getSavedToken();
  //   state = state.copyWith(token: token, isInitialized: true);
  //   _notify();
  // }

  Future<void> init() async {
  try {
    final token = await repository.getSavedToken();
    print('🔑 Loaded token: $token');
    state = state.copyWith(token: token, isInitialized: true);
  } catch (e, st) {
    print('❌ Error loading token: $e');
    print('$st');
    state = state.copyWith(isInitialized: true);
  }
  _notify();
}

  void _notify() => _controller.add(null);

  Future<void> login(String email, String password, GraphQLClient client) async {
    state = state.copyWith(isLoading: true, error: null);
    _notify();
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
    _notify();
  }

  Future<void> register(String email, String password, GraphQLClient client) async {
    state = state.copyWith(isLoading: true, error: null);
    _notify();
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
    _notify();
  }

  Future<void> logout() async {
    await repository.logout();
    state = AuthState(isInitialized: true, token: null);
    _notify();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}