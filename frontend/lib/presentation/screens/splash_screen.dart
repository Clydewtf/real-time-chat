import 'package:flutter/material.dart';
import '../widgets/common/app_loading_indicator.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: AppLoadingIndicator(),
    );
  }
}