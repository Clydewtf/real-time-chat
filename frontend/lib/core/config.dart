import 'package:flutter_dotenv/flutter_dotenv.dart';


class AppConfig {
  static String get graphqlEndpoint =>
      dotenv.env['HASURA_GRAPHQL_ENDPOINT'] ?? '';
  static String get adminSecret => dotenv.env['HASURA_ADMIN_SECRET'] ?? '';
}

// class AppConfig {
//   static const graphqlEndpoint = String.fromEnvironment(
//       'HASURA_GRAPHQL_ENDPOINT', defaultValue: 'http://localhost:8080/v1/graphql');
//   static const adminSecret = String.fromEnvironment(
//       'HASURA_ADMIN_SECRET', defaultValue: '');
// }