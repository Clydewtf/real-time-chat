import 'package:graphql_flutter/graphql_flutter.dart';


class UserRemoteDatasource {
  Future<List<Map<String, dynamic>>> searchUsers(GraphQLClient client, String query) async {
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

    final result = await client.query(
      QueryOptions(
        document: gql(gqlQuery),
        variables: {
          'search': "%$query%",
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final list = result.data!['users'] as List<dynamic>;
    return List<Map<String, dynamic>>.from(list);
  }
}