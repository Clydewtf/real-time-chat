import 'package:drift/drift.dart';


class ChatsTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().withDefault(const Constant('private'))();
  TextColumn get title => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get description => text().nullable()();

  TextColumn get participantIds => text().withDefault(const Constant(''))();

  TextColumn get lastMessageId => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  TextColumn get createdBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}