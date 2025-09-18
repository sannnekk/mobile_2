import 'dart:async';
import 'package:flutter/foundation.dart';

/// A utility class for debouncing function calls
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Calls [action] after [delay] has passed since the last call to debounce.
  /// If debounce is called again before the delay expires, the previous call is cancelled.
  void debounce(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending debounced call
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Disposes the debouncer, cancelling any pending calls
  void dispose() {
    cancel();
  }
}

/// Extension on functions to add debouncing capability
extension DebounceExtension on VoidCallback {
  /// Returns a debounced version of this callback
  VoidCallback debounced(Duration delay) {
    final debouncer = Debouncer(delay: delay);
    return () => debouncer.debounce(this);
  }
}
