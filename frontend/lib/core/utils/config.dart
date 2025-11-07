import 'package:flutter_dotenv/flutter_dotenv.dart';


class AppConfig {
  static String get graphqlEndpoint =>
      dotenv.env['HASURA_GRAPHQL_ENDPOINT'] ?? '';
  static String get adminSecret => dotenv.env['HASURA_ADMIN_SECRET'] ?? '';
}