import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'logic/services/providers.dart';
import 'presentation/screens/auth_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(dynamicGraphQLClientProvider);

    return GraphQLProvider(
      client: ValueNotifier(client),
      child: MaterialApp(
        title: 'Chat App',
        home: AuthTestScreen(),
      ),
    );
  }
}