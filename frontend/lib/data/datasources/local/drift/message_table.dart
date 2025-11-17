import 'package:drift/drift.dart';


class MessagesTable extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  TextColumn get type =>
      text().withDefault(const Constant('text'))();

  TextColumn get status =>
      text().withDefault(const Constant('sent'))();

  DateTimeColumn get editedAt => dateTime().nullable()();
  TextColumn get replyToMessageId => text().nullable()();
  TextColumn get attachmentUrl => text().nullable()();
  TextColumn get localTempId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}