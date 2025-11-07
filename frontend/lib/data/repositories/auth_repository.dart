import 'package:frontend/data/datasources/auth_local_datasource.dart';
import 'package:frontend/data/datasources/auth_remote_datasource.dart';
import 'package:graphql_flutter/graphql_flutter.dart';


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

  Future<void> logout() => local.clearToken();
}