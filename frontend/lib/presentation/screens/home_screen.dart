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

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Chats',
          style: textTheme.titleLarge?.copyWith(color: colors.onPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colors.onPrimary),
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
              backgroundColor: colors.secondary,
              child: Text(
                chat['name']![0],
                style: textTheme.titleMedium
                    ?.copyWith(color: colors.onSecondary),
              ),
            ),
            title: Text(
              chat['name']!,
              style:
                  textTheme.bodyLarge?.copyWith(color: colors.onSurface),
            ),
            subtitle: Text(
              chat['message']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
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