import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/services/providers.dart';


class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final client = ref.read(dynamicGraphQLClientProvider);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Sign in',
          style: textTheme.titleLarge?.copyWith(color: colors.onPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              style: textTheme.bodyLarge?.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 20),
            if (authState.isLoading)
              CircularProgressIndicator(color: colors.primary),
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  authState.error!,
                  style: textTheme.bodyMedium?.copyWith(color: colors.error),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      ref.read(authNotifierProvider.notifier).login(
                          emailController.text,
                          passwordController.text,
                          client);
                    },
              child: Text('Sign in', style: textTheme.labelLarge),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/register'),
              child: Text(
                'No account? Sign up',
                style: textTheme.bodyMedium?.copyWith(color: colors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}