import 'package:graphql_flutter/graphql_flutter.dart';


class ChatRemoteDatasource  {
  /// Creates a private chat between two users
  /// Returns chatId
  Future<Map<String, dynamic>> createPrivateChat({required GraphQLClient client, required String userA, required String userB,}) async {
    const createPrivateChatMutation = '''
      mutation CreatePrivateChat(\$userA: uuid!, \$userB: uuid!) {
        create_private_chat(args: {user_a: \$userA, user_b: \$userB}) {
          id
          type
          title
          avatar_url
          description
          last_message_id
          created_at
          updated_at
          created_by
          chat_participants {
            user_id
          }
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(createPrivateChatMutation),
        variables: {
          'userA': userA,
          'userB': userB,
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['create_private_chat']['id'] as Map<String, dynamic>;
  }

  /// Fetch all chats for current user
  Future<List<Map<String, dynamic>>> getChatsForUser(GraphQLClient client, String userId,) async {
    const getUserChatsMutation = '''
      query GetUserChats(\$userId: uuid!) {
        chats(
          where: {
            chat_participants: {
              user_id: { _eq: \$userId}
            }
          }
          order_by: { updated_at: desc}
        ) {
          id
          created_at
          updated_at
          avatar_url
          description
          title
          last_message_id
          chat_participants {
            user_id
          }
        }
      }
    ''';

    final result = await client.mutate(
      MutationOptions(
        document: gql(getUserChatsMutation),
        variables: {'userId': userId,},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return List<Map<String, dynamic>>.from(
      result.data!['chats'],
    );
  }
}