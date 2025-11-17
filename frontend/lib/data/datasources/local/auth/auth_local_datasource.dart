import 'package:drift/drift.dart';
import '../drift/app_database.dart';


class AuthLocalDatasource {
  final AppDatabase db;
  AuthLocalDatasource(this.db);

  Future<void> saveToken(String token) async {
    await db.into(db.authTokens).insert(AuthTokensCompanion(token: Value(token)));
  }

  Future<String?> getToken() async {
    final query = await db.select(db.authTokens).getSingleOrNull();
    return query?.token;
  }

  Future<void> clearToken() async {
    await db.delete(db.authTokens).go();
  }
}