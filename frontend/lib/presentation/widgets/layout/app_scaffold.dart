import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';


/// Universal wrapper for all app screens
/// Provides a consistent background, indents, AppBar, and bottom navbar (if needed)
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool useSafeArea;
  final EdgeInsets? padding;
  final bool showAppBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.bottomNavigationBar,
    this.actions,
    this.centerTitle = false,
    this.useSafeArea = true,
    this.padding,
    this.showAppBar = true,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldContent = Column(
      children: [
        if (showAppBar && title != null)
          AppBar(
            title: Text(title!),
            centerTitle: centerTitle,
            actions: actions,
          ),
        Expanded(
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.l),
            child: body,
          ),
        ),
      ],
    );

    final content = useSafeArea ? SafeArea(child: scaffoldContent) : scaffoldContent;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}