import 'package:graphql_flutter/graphql_flutter.dart';


class AuthRemoteDatasource  {
  Future<Map<String, dynamic>> login(GraphQLClient client, String email, String password) async {
    const loginMutation = '''
      mutation LoginUser(\$email: String!, \$password: String!) {
        loginUser(email: \$email, password: \$password) {
          success
          message
          token
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(loginMutation),
        variables: {'email': email, 'password': password},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['loginUser'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(GraphQLClient client, String email, String password) async {
    const registerMutation = '''
      mutation RegisterUser(\$email: String!, \$password: String!) {
        registerUser(email: \$email, password: \$password) {
          success
          message
          token
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(registerMutation),
        variables: {'email': email, 'password': password},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['registerUser'] as Map<String, dynamic>;
  }
}