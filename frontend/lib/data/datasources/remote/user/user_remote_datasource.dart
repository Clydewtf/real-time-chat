import 'package:graphql_flutter/graphql_flutter.dart';

class UserRemoteDatasource {
  final GraphQLClient _client;

  UserRemoteDatasource(this._client);

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    const gqlQuery = '''
      query GetUsers(\$search: String!) {
        users(where: {username: {_ilike: \$search}}) {
          id
          username
          display_name
          avatar_url
        }
      }
    ''';

    final result = await _client.query(
      QueryOptions(document: gql(gqlQuery), variables: {'search': "%$query%"}),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final list = result.data!['users'] as List<dynamic>;
    return List<Map<String, dynamic>>.from(list);
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    const gqlQuery = '''
      query GetUser(\$id: uuid!) {
        users_by_pk(id: \$id) {
          id
          username
        }
      }
    ''';

    final result = await _client.query(
      QueryOptions(document: gql(gqlQuery), variables: {'id': userId}),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['users_by_pk'] as Map<String, dynamic>?;
  }
}
