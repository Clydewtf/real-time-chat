import 'package:graphql_flutter/graphql_flutter.dart';
import '../datasources/remote/user/user_remote_datasource.dart';
import '../dtos/user_dto.dart';


class UserRepository {
  final UserRemoteDatasource remote;

  UserRepository({required this.remote});

  Future<List<UserDto>> searchUsers(GraphQLClient client, String query) async {
    final rawList = await remote.searchUsers(client, query);
    return rawList.map((e) => UserDto.fromJson(e)).toList();
  }
}