import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/services/providers.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockChats = List.generate(
      8,
      (index) => {
        'name': 'User $index',
        'message': 'Last message from User $index',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: mockChats.length,
        itemBuilder: (context, index) {
          final chat = mockChats[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(chat['name']![0]),
            ),
            title: Text(chat['name']!),
            subtitle: Text(
              chat['message']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              // Placeholder for chat details navigation
            },
          );
        },
      ),
    );
  }
}
