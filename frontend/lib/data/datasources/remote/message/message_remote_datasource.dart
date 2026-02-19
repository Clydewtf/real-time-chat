import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../domain/value_objects/message_type.dart';

class MessageRemoteDatasource {
  /// Send message
  Future<Map<String, dynamic>> sendMessage({
    required GraphQLClient client,
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? attachmentUrl,
    String? localTempId,
  }) async {
    const sendMessageMutation = '''
      mutation SendMessage(
        \$chatId: uuid!
        \$content: String!
        \$type: String!
        \$replyToMessageId: uuid
        \$attachmentUrl: String
        \$localTempId: String
      ) {
        insert_messages_one(
          object: {
            chat_id: \$chatId
            content: \$content
            type: \$type
            reply_to_message_id: \$replyToMessageId
            attachment_url: \$attachmentUrl
            local_temp_id: \$localTempId
          }
        ) {
          id
          chat_id
          sender_id
          content
          created_at
          type
          status
          edited_at
          reply_to_message_id
          attachment_url
          local_temp_id
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(sendMessageMutation),
        variables: {
          'chatId': chatId,
          'content': content,
          'type': type.name,
          'replyToMessageId': replyToMessageId,
          'attachmentUrl': attachmentUrl,
          'localTempId': localTempId,
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['insert_messages_one'] as Map<String, dynamic>;
  }

  /// Load messages for chat
  Future<List<Map<String, dynamic>>> getMessages(
    GraphQLClient client,
    String chatId,
  ) async {
    const getMessagesQuery = '''
      query GetMessages(\$chatId: uuid!) {
        messages(
          where: { chat_id: { _eq: \$chatId } }
          order_by: { created_at: asc }
        ) {
          id
          chat_id
          sender_id
          content
          created_at
          type
          status
          edited_at
          reply_to_message_id
          attachment_url
          local_temp_id
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(getMessagesQuery),
        variables: {'chatId': chatId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return List<Map<String, dynamic>>.from(result.data!['messages']);
  }

  /// Subscribe to new messages
  Stream<Map<String, dynamic>> subscribeNewMessages(
    GraphQLClient client,
    String chatId,
  ) {
    const newMessagesSubscription = '''
      subscription OnNewMessage(\$chatId: uuid!) {
        messages(
          where: { chat_id: { _eq: \$chatId } }
          order_by: { created_at: desc }
          limit: 1
        ) {
          id
          chat_id
          sender_id
          content
          created_at
          type
          status
          edited_at
          reply_to_message_id
          attachment_url
          local_temp_id
        }
      }
    ''';

    final options = SubscriptionOptions(
      document: gql(newMessagesSubscription),
      variables: {'chatId': chatId},
    );

    return client
        .subscribe(options)
        .where((result) {
          if (result.hasException) {
            throw Exception(result.exception.toString());
          }

          final list = result.data?['messages'] as List<dynamic>?;

          return list != null && list.isNotEmpty;
        })
        .map((result) {
          final list = result.data!['messages'] as List<dynamic>;
          return list.first as Map<String, dynamic>;
        });
  }
}
