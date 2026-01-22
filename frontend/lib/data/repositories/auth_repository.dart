import 'package:frontend/data/datasources/local/auth/auth_local_datasource.dart';
import 'package:frontend/data/datasources/remote/auth/auth_remote_datasource.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class AuthRepository {
  final AuthRemoteDatasource remote;
  final AuthLocalDatasource local;

  AuthRepository({required this.remote, required this.local});

  Future<Map<String, dynamic>> login(GraphQLClient client, String email, String password) async {
    final result = await remote.login(client, email, password);
    if (result['success'] == true) {
      await local.saveToken(result['token']);
    }
    return result;
  }

  Future<Map<String, dynamic>> register(GraphQLClient client, String email, String password) async {
    final result = await remote.register(client, email, password);
    if (result['success'] == true) {
      await local.saveToken(result['token']);
    }
    return result;
  }

  Future<String?> getSavedToken() => local.getToken();

  Future<String?> getCurrentUserId() async {
    final token = await getSavedToken();
    if (token == null) return null;

    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() => local.clearToken();
}