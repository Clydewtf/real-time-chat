import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/services/providers.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_divider.dart';
import '../../widgets/constants/app_spacing.dart';
import '../../widgets/layout/app_scaffold.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      showAppBar: false,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          const SizedBox(height: AppSpacing.l),
          Center(
            child: Column(
              children: [
                const AppAvatar(
                  imageUrl: 'https://i.pravatar.cc/150?img=12',
                  size: 80,
                ),
                const SizedBox(height: AppSpacing.m),
                Text('John Doe', style: textTheme.titleMedium),
                Text('john@example.com', style: textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          const AppDivider(),
          const SizedBox(height: AppSpacing.l),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile settings', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.m),
                AppButton(
                  label: 'Edit profile',
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.s),
                AppButton(
                  label: 'Log out',
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    ref.invalidate(currentUserIdProvider);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}