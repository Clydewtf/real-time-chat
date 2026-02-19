import 'package:graphql_flutter/graphql_flutter.dart';

enum AppConnectionState { online, connecting, offline }

Future<bool> pingGraphQL(GraphQLClient client) async {
  const query = r'''
    query Ping {
      __typename
    }
  ''';

  try {
    final result = await client.query(
      QueryOptions(document: gql(query), fetchPolicy: FetchPolicy.networkOnly),
    );

    return !result.hasException;
  } catch (_) {
    return false;
  }
}
