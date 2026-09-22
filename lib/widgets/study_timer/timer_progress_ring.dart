import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/app_theme_extension.dart';
import '../goal_details_modern/progress/progress_circle.dart';
import 'timer_controls.dart';

/// A progress ring around the timer that breathes while the session runs.
///
/// Two jobs in one element: it shows how far the session has come, and its
/// pulse is the only sign on an otherwise static screen that the app is still
/// running. It replaces the old progress bar rather than sitting beside it.
///
/// The pulse stops whenever the timer is not running, which is what makes
/// "paused" legible without a label.
class TimerProgressRing extends StatefulWidget {
  final int elapsedSeconds;
  final int targetMinutes;
  final TimerState timerState;

  /// Builds what is drawn inside the ring -- the timer readout.
  ///
  /// A builder rather than a plain widget so the readout can be handed the
  /// same progress figure that draws the arc. The percentage used to be
  /// computed separately from whole seconds, which let the text read 99% while
  /// the arc had visually closed the loop.
  final Widget Function(BuildContext context, int progressPercentage)
      childBuilder;

  final double diameter;

  const TimerProgressRing({
    super.key,
    required this.elapsedSeconds,
    required this.targetMinutes,
    required this.timerState,
    required this.childBuilder,
    this.diameter = 300,
  });

  @override
  State<TimerProgressRing> createState() => _TimerProgressRingState();
}

class _TimerProgressRingState extends State<TimerProgressRing>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  static const double _strokeWidth = 7;
  static const double _trackAlpha = 0.30;
  Duration? _secondStartedAt;
  Duration _frameNow = Duration.zero;

  /// The arc's fill, 0-1, republished on every vsync while the timer runs.
  ///
  /// A notifier rather than setState: this changes sixty times a second for
  /// the length of a session, and setState would rebuild the whole subtree
  /// each time. The AnimatedBuilder below already rebuilds for the pulse, so
  /// listening to one more source costs nothing.
  final ValueNotifier<double> _arc = ValueNotifier<double>(0);

  static const double _minRingScale = 1.0;
  static const double _maxRingScale = 1.067;

  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (widget.timerState != TimerState.running) return;
      _frameNow = elapsed;
      _secondStartedAt ??= elapsed;
      _publishArc();
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    WidgetsBinding.instance.addObserver(this);
    _syncPulse();
    _syncTicker();
    _publishArc();
  }

  /// Pushes the current fill to [_arc], which is what actually repaints.
  void _publishArc() => _arc.value = _progress;

  @override
  void didUpdateWidget(TimerProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timerState != widget.timerState) {
      _syncPulse();
      _syncTicker();
    }

    if (oldWidget.elapsedSeconds != widget.elapsedSeconds ||
        oldWidget.targetMinutes != widget.targetMinutes) {
      final wentBackwards = widget.elapsedSeconds < oldWidget.elapsedSeconds;
      _secondStartedAt = wentBackwards ? null : _frameNow;
      _publishArc();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Clear the mark before restarting: it holds a ticker timestamp from
      // before the app went away, and the ticker resumes at a much later
      // elapsed value. Left in place, the first frame back would measure the
      // whole backgrounded stretch as "time into the current second" and jump
      // the arc a full second ahead of the clock.
      _secondStartedAt = null;
      _syncPulse();
      _syncTicker();
      _publishArc();
    } else {
      _controller.stop();
      _ticker.stop();
      _secondStartedAt = null;
      _publishArc();
    }
  }

  void _syncTicker() {
    if (widget.timerState == TimerState.running) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      _ticker.stop();
      _secondStartedAt = null;
      _publishArc();
    }
  }

  void _syncPulse() {
    if (widget.timerState == TimerState.running) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _arc.dispose();
    super.dispose();
  }

  double get _progress {
    if (widget.targetMinutes <= 0) return 0;
    final target = widget.targetMinutes * 60;
    return (_continuousElapsed / target).clamp(0.0, 1.0);
  }

  /// Where the arc thinks it is within the current second.
  ///
  /// Exposed for the test that a stale mark does not survive backgrounding --
  /// the resulting jump cannot be produced in a widget test, because a test
  /// Ticker's elapsed clock does not advance while it is stopped.
  @visibleForTesting
  Duration? get secondStartedAtForTest => _secondStartedAt;

  double get _continuousElapsed {
    final whole = widget.elapsedSeconds.toDouble();
    if (widget.timerState != TimerState.running) return whole;

    final startedAt = _secondStartedAt;
    if (startedAt == null) return whole;

    final into = (_frameNow - startedAt).inMilliseconds / 1000;
    return whole + into.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // accent, not accentStrong: TimerDisplay already uses it here, and it
    // resolves to the same colour in both modes.
    final colour = colors.accent;

    return SizedBox(
      width: widget.diameter,
      height: widget.diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_controller, _arc]),
            builder: (context, _) {
              final t = _controller.isAnimating
                  ? Curves.easeInOut.transform(_controller.value)
                  : 0.0;
              final scale =
                  _minRingScale + ((_maxRingScale - _minRingScale) * t);

              return Transform.scale(
                scale: scale,
                child: CustomPaint(
                  size: Size.square(widget.diameter),
                  painter: CircularProgressPainter(
                    progress: _arc.value,
                    color: colour,
                    trackColor: colour,
                    strokeWidth: _strokeWidth,
                    trackAlpha: _trackAlpha,
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder<double>(
            valueListenable: _arc,
            builder: (context, value, _) =>
                widget.childBuilder(context, (value * 100).toInt()),
          ),
        ],
      ),
    );
  }
}

