import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/app_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'logic/services/providers.dart';
import 'core/utils/theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final client = ref.watch(dynamicGraphQLClientProvider);

    return GraphQLProvider(
      client: ValueNotifier(client),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Chat App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }
}