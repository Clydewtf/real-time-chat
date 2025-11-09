import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'auth_local_datasource.g.dart';


class AuthTokens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get token => text()();
}

@DriftDatabase(tables: [AuthTokens])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_db.sqlite'));
    return NativeDatabase(file);
  });
}

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