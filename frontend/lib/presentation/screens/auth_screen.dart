import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/services/providers.dart';


class AuthTestScreen extends ConsumerWidget {
  AuthTestScreen({super.key});

  final emailController = TextEditingController(text: 'test@example.com');
  final passwordController = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final client = ref.read(dynamicGraphQLClientProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auth Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            if (authState.isLoading) const CircularProgressIndicator(),
            if (authState.error != null) Text(authState.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier)
                    .login(emailController.text, passwordController.text, client);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier)
                    .register(emailController.text, passwordController.text, client);
              },
              child: const Text('Register'),
            ),
            if (authState.token != null) Text('Token: ${authState.token}'),
          ],
        ),
      ),
    );
  }
}