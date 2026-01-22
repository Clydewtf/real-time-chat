import 'dart:async';
import 'package:flutter/foundation.dart';


/// Custom helper for go_router to refresh when auth state changes.
/// Works just like the old GoRouterRefreshStream from older versions.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}