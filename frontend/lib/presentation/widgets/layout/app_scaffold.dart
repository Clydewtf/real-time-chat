import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/logic/services/providers.dart';
import 'package:frontend/presentation/widgets/common/app_loading_indicator.dart';
import '../../../logic/services/connection_service.dart';
import '../constants/app_spacing.dart';

/// Universal wrapper for all app screens
/// Provides a consistent background, indents, AppBar, and bottom navbar (if needed)
class AppScaffold extends ConsumerStatefulWidget {
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
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  AppConnectionState _previousState = AppConnectionState.online;
  bool _showRefreshing = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppConnectionState?>(
      connectionStateProvider.select((value) => value.value),
      (prev, next) {
        if (next == null) return;

        if (_previousState == AppConnectionState.offline &&
            next == AppConnectionState.online) {
          setState(() => _showRefreshing = true);

          _refreshTimer?.cancel();
          _refreshTimer = Timer(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() => _showRefreshing = false);
            }
          });
        }

        _previousState = next;
      },
    );

    final connectionAsync = ref.watch(connectionStateProvider);
    final connectionState = connectionAsync.value ?? AppConnectionState.online;

    Widget titleWidget;

    if (connectionState == AppConnectionState.offline) {
      titleWidget = Row(
        key: const ValueKey('offline'),
        mainAxisSize: MainAxisSize.min,
        children: const [
          AppLoadingIndicator(
            size: AppSpacing.m,
            strokeWidth: 2,
            color: Colors.yellow,
          ),
          SizedBox(width: AppSpacing.s),
          Text('Connection...'),
        ],
      );
    } else if (_showRefreshing) {
      titleWidget = Row(
        key: const ValueKey('refreshing'),
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.sync, size: AppSpacing.m),
          SizedBox(width: AppSpacing.s),
          Text('Update...'),
        ],
      );
    } else {
      titleWidget = Text(widget.title ?? '', key: const ValueKey('online'));
    }

    final scaffoldContent = Column(
      children: [
        if (widget.showAppBar && widget.title != null)
          AppBar(
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: titleWidget,
            ),
            centerTitle: widget.centerTitle,
            actions: widget.actions,
          ),
        Expanded(
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(AppSpacing.m),
            child: widget.body,
          ),
        ),
      ],
    );

    final content = widget.useSafeArea
        ? SafeArea(child: scaffoldContent)
        : scaffoldContent;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: content,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
    );
  }
}

// class AppScaffold extends ConsumerWidget {
//   final String? title;
//   final Widget body;
//   final Widget? bottomNavigationBar;
//   final List<Widget>? actions;
//   final bool centerTitle;
//   final bool useSafeArea;
//   final EdgeInsets? padding;
//   final bool showAppBar;
//   final Widget? floatingActionButton;
//   final bool resizeToAvoidBottomInset;

//   const AppScaffold({
//     super.key,
//     this.title,
//     required this.body,
//     this.bottomNavigationBar,
//     this.actions,
//     this.centerTitle = false,
//     this.useSafeArea = true,
//     this.padding,
//     this.showAppBar = true,
//     this.floatingActionButton,
//     this.resizeToAvoidBottomInset = true,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final connectivity = ref.watch(connectionStateProvider);

//     final isOffline = connectivity.when(
//       data: (result) => result == ConnectivityResult.none,
//       error: (_, __) => false,
//       loading: () => false,
//     );

//     final scaffoldContent = Column(
//       children: [
//         if (showAppBar && title != null)
//           AppBar(
//             title: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 250),
//               child: isOffline
//                   ? Row(
//                       key: const ValueKey('offline'),
//                       mainAxisSize: MainAxisSize.min,
//                       children: const [
//                         AppLoadingIndicator(size: AppSpacing.m, strokeWidth: 2),
//                         SizedBox(width: AppSpacing.s),
//                         Text('Connection...'),
//                       ],
//                     )
//                   : Text(title!, key: const ValueKey('online')),
//             ),
//             centerTitle: centerTitle,
//             actions: actions,
//           ),
//         Expanded(
//           child: Padding(
//             padding: padding ?? const EdgeInsets.all(AppSpacing.l),
//             child: body,
//           ),
//         ),
//       ],
//     );

//     final content = useSafeArea
//         ? SafeArea(child: scaffoldContent)
//         : scaffoldContent;

//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       body: content,
//       bottomNavigationBar: bottomNavigationBar,
//       floatingActionButton: floatingActionButton,
//       resizeToAvoidBottomInset: resizeToAvoidBottomInset,
//     );
//   }
// }
