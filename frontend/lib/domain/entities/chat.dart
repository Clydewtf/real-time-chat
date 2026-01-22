import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';


@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required String id,
    String? type,
    String? title,
    String? avatarUrl,
    String? description,
    required List<String> participantIds,
    String? lastMessageId,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}