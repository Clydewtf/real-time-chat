import 'package:drift/drift.dart';


class AuthTokens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get token => text()();
}