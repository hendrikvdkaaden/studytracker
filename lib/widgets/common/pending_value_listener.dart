import 'package:flutter/material.dart';

/// Watches [notifier] for the whole life of its subtree and hands each
/// non-null value to [onValue] exactly once.
///
/// Exists because of a real bug: the streak celebration was drained from a
/// post-frame callback in HomePage.initState, which runs once at cold start.
/// A streak grows mid-session, hours after that callback has fired, so the
/// value was set and then sat unread until the next launch -- finishing a
/// session produced no dialog at all.
///
/// Pulled out of HomePage so the wiring can be tested on its own. HomePage
/// builds four tab screens that reach for Riverpod providers and Hive as they
/// are constructed, so a test of the real thing would exercise the harness
/// rather than the subscription.
class PendingValueListener<T extends Object> extends StatefulWidget {
  final ValueNotifier<T?> notifier;

  /// Called with each value the notifier receives, one at a time. Awaited, so
  /// a value arriving while the previous is still being handled waits rather
  /// than stacking on top of it.
  final Future<void> Function(T value) onValue;

  final Widget child;

  const PendingValueListener({
    super.key,
    required this.notifier,
    required this.onValue,
    required this.child,
  });

  @override
  State<PendingValueListener<T>> createState() =>
      _PendingValueListenerState<T>();
}

class _PendingValueListenerState<T extends Object>
    extends State<PendingValueListener<T>> {
  /// True while [widget.onValue] is running, so a second value cannot start
  /// while the first is still on screen.
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onChanged);
    // A value parked before this widget existed still counts -- the splash
    // screen writes one before HomePage is built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onChanged());
  }

  @override
  void didUpdateWidget(PendingValueListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_onChanged);
      widget.notifier.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (widget.notifier.value == null) return;
    // Deferred a frame: the notifier is typically set just before a route
    // pops, and showing a dialog immediately would push it onto a route that
    // is still being torn down.
    WidgetsBinding.instance.addPostFrameCallback((_) => _drain());
    // A post-frame callback only runs when a frame is actually produced, and
    // nothing here requests one -- the notifier is written from outside the
    // build pipeline. Without this the drain waits for whatever happens to
    // schedule the next frame, which is the same implicit dependency that
    // left the celebration unread in the first place.
    WidgetsBinding.instance.scheduleFrame();
  }

  Future<void> _drain() async {
    if (!mounted || _handling) return;

    final value = widget.notifier.value;
    if (value == null) return;

    // Cleared before handing over, so a rebuild cannot surface the same value
    // twice.
    widget.notifier.value = null;

    _handling = true;
    try {
      await widget.onValue(value);
    } finally {
      _handling = false;
      // Something may have arrived while this one was on screen.
      if (mounted && widget.notifier.value != null) _drain();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
