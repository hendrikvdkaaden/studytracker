import 'package:deadly/l10n/app_localizations.dart';
import 'package:deadly/theme/app_theme_extension.dart';
import 'package:deadly/widgets/goal_details_modern/progress/progress_circle.dart';
import 'package:deadly/widgets/study_timer/timer_controls.dart';
import 'package:deadly/widgets/study_timer/timer_display.dart';
import 'package:deadly/widgets/study_timer/timer_progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The ring shows progress and, while the session runs, breathes.
///
/// The pulse is the whole point: on a screen where nothing else moves it is
/// the only sign the app is alive. So these tests assert that the track's
/// opacity *changes between frames*, not that a ring exists -- a ring with a
/// dead controller looks identical in a single frame, which is exactly how an
/// earlier animation in this project shipped looking correct.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required TimerState state,
    int elapsedSeconds = 600,
    int targetMinutes = 50,
    bool dark = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [dark ? AppTheme.dark : AppTheme.light],
        ),
        home: Scaffold(
          body: TimerProgressRing(
            elapsedSeconds: elapsedSeconds,
            targetMinutes: targetMinutes,
            timerState: state,
            childBuilder: (context, _) => const Text('25:00'),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// The ring's current scale. This is what breathes -- the track's opacity
  /// is fixed, because a shifting tint read as the ring changing colour
  /// rather than as motion.
  double ringScale(WidgetTester tester) {
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(TimerProgressRing),
            matching: find.byType(Transform),
          )
          .first,
    );
    return transform.transform.getMaxScaleOnAxis();
  }

  CircularProgressPainter painter(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find
          .descendant(
            of: find.byType(TimerProgressRing),
            matching: find.byType(CustomPaint),
          )
          .first,
    );
    return paint.painter! as CircularProgressPainter;
  }

  group('the pulse', () {
    testWidgets('breathes while the session runs', (tester) async {
      // Never pumpAndSettle here: a repeating controller never quiesces, so it
      // would time out. Fixed-duration pumps sample two points of the breath.
      await pump(tester, state: TimerState.running);

      final first = ringScale(tester);
      await tester.pump(const Duration(milliseconds: 900));
      final second = ringScale(tester);

      expect(
        second,
        isNot(closeTo(first, 0.0001)),
        reason: 'a still ring is indistinguishable from a dead controller',
      );
    });

    testWidgets('grows far enough to be seen', (tester) async {
      // Two earlier attempts were technically animating but invisible: an
      // alpha swing of 1.08 contrast, then a scale so small it read as
      // nothing. On a 300pt ring, 15pt of growth is the floor worth having.
      await pump(tester, state: TimerState.running);

      var lowest = 99.0;
      var highest = 0.0;
      for (var i = 0; i < 40; i++) {
        final scale = ringScale(tester);
        lowest = scale < lowest ? scale : lowest;
        highest = scale > highest ? scale : highest;
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect((highest - lowest) * 300, greaterThanOrEqualTo(15));
    });

    testWidgets('holds still when paused', (tester) async {
      await pump(tester, state: TimerState.paused);

      final first = ringScale(tester);
      await tester.pump(const Duration(milliseconds: 900));

      expect(ringScale(tester), first);
    });

    testWidgets('a paused ring lets the tree settle', (tester) async {
      // The strongest assertion available: pumpAndSettle only returns when
      // nothing is animating, so this cannot pass while a ticker runs.
      await pump(tester, state: TimerState.paused);

      await tester.pumpAndSettle();
    });

    testWidgets('does not breathe before the session starts', (tester) async {
      await pump(tester, state: TimerState.initial, elapsedSeconds: 0);

      await tester.pumpAndSettle();
    });

    testWidgets('stops once the session is complete', (tester) async {
      await pump(tester, state: TimerState.completed, elapsedSeconds: 3000);

      await tester.pumpAndSettle();
    });

    testWidgets('starts breathing when the timer is started', (tester) async {
      await pump(tester, state: TimerState.paused);
      await tester.pumpAndSettle();

      await pump(tester, state: TimerState.running);
      final first = ringScale(tester);
      await tester.pump(const Duration(milliseconds: 900));

      expect(ringScale(tester), isNot(closeTo(first, 0.0001)));
    });
  });

  group('progress', () {
    testWidgets('reflects how far the session has come', (tester) async {
      await pump(
        tester,
        state: TimerState.paused,
        elapsedSeconds: 1500,
        targetMinutes: 50,
      );

      expect(painter(tester).progress, closeTo(0.5, 0.001));
    });

    testWidgets('never exceeds a full ring', (tester) async {
      // Overtime is possible: the timer keeps counting past the target.
      await pump(
        tester,
        state: TimerState.paused,
        elapsedSeconds: 9000,
        targetMinutes: 50,
      );

      expect(painter(tester).progress, 1.0);
    });

    testWidgets('a zero-length target does not divide by zero',
        (tester) async {
      await pump(
        tester,
        state: TimerState.paused,
        elapsedSeconds: 600,
        targetMinutes: 0,
      );

      expect(painter(tester).progress, 0);
    });
  });

  testWidgets('the readout is drawn inside the ring', (tester) async {
    await pump(tester, state: TimerState.paused);

    expect(
      find.descendant(
        of: find.byType(TimerProgressRing),
        matching: find.text('25:00'),
      ),
      findsOneWidget,
    );
  });

  group('the readout sits inside the ring', () {
    // Both regressions from the first attempt: 72px digits measured 350pt
    // against a 280pt ring and spilled out either side, and the column
    // stretched to full height so everything stacked against the top edge.
    Future<void> pumpWithReadout(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(extensions: const [AppTheme.dark]),
          home: Scaffold(
            body: Center(
              child: TimerProgressRing(
                elapsedSeconds: 66,
                targetMinutes: 60,
                timerState: TimerState.paused,
                childBuilder: (context, progressPercentage) => TimerDisplay(
                  remainingSeconds: 3534,
                  phaseLabel: 'Paused',
                  progressPercentage: progressPercentage,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the digits fit within the circle', (tester) async {
      await pumpWithReadout(tester);

      final ring = tester.getRect(find.byType(TimerProgressRing));
      final digits = tester.getRect(find.text('58:54'));

      expect(digits.left, greaterThan(ring.left));
      expect(digits.right, lessThan(ring.right));
    });

    testWidgets('the readout is centred, not stacked at the top',
        (tester) async {
      await pumpWithReadout(tester);

      final ring = tester.getRect(find.byType(TimerProgressRing));
      final readout = tester.getRect(find.byType(TimerDisplay));

      expect(readout.center.dy, closeTo(ring.center.dy, 1));
      expect(
        readout.height,
        lessThan(ring.height),
        reason: 'a stretched column pushes its children against the top',
      );
    });
  });

  group('the breathing ring', () {
    testWidgets('sits at its resting size when paused', (tester) async {
      await pump(tester, state: TimerState.paused);

      expect(ringScale(tester), closeTo(1.0, 0.0001));
    });

    testWidgets('grows past its resting size at the peak of the breath',
        (tester) async {
      await pump(tester, state: TimerState.running);

      var highest = 0.0;
      for (var i = 0; i < 40; i++) {
        final scale = ringScale(tester);
        highest = scale > highest ? scale : highest;
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(highest, greaterThan(1.0));
    });

    testWidgets('the track no longer breathes', (tester) async {
      // The size change replaced the alpha pulse. Two things changing at once
      // was restless, and the tint shift was the part that read wrong.
      await pump(tester, state: TimerState.running);

      final first = painter(tester).trackAlpha;
      await tester.pump(const Duration(milliseconds: 900));

      expect(painter(tester).trackAlpha, first);
    });
  });

  group('the arc fills continuously', () {
    // The timer ticks in whole seconds, so the arc used to step once a second.
    // Between ticks it now fills from the fraction of the current second that
    // has already passed.
    testWidgets('advances between two ticks', (tester) async {
      await pump(tester, state: TimerState.running, elapsedSeconds: 600);

      final first = painter(tester).progress;
      await tester.pump(const Duration(milliseconds: 400));
      final second = painter(tester).progress;

      expect(
        second,
        greaterThan(first),
        reason: 'a jump once a second is exactly what this removes',
      );
    });

    testWidgets('never runs ahead of the next whole second', (tester) async {
      // A late frame or a backgrounded app must not let the arc overtake the
      // clock it represents.
      await pump(
        tester,
        state: TimerState.running,
        elapsedSeconds: 600,
        targetMinutes: 50,
      );

      await tester.pump(const Duration(seconds: 5));

      expect(painter(tester).progress, lessThanOrEqualTo(601 / 3000));
    });

    testWidgets('a paused arc sits still on its whole second', (tester) async {
      // Creeping forward after the timer stopped would be a lie.
      await pump(tester, state: TimerState.paused, elapsedSeconds: 600);

      final first = painter(tester).progress;
      await tester.pump(const Duration(milliseconds: 900));

      expect(painter(tester).progress, first);
      expect(first, closeTo(600 / 3000, 0.0001));
    });

    testWidgets('drops its place in the second when the app goes away',
        (tester) async {
      // The bug: backgrounding called _ticker.stop() directly rather than
      // going through _syncTicker, so the mark saying when the current second
      // began survived. The ticker resumes from a much later elapsed value, so
      // the first frame back would measure the whole backgrounded stretch as
      // "time into this second", clamp it to a full second, and let the arc
      // overtake the clock it draws.
      //
      // Asserted on the state rather than on a rendered frame: a test Ticker's
      // elapsed clock does not advance while stopped, so the stale gap that
      // causes the visible jump cannot be produced here.
      await pump(
        tester,
        state: TimerState.running,
        elapsedSeconds: 600,
        targetMinutes: 50,
      );
      await tester.pump(const Duration(milliseconds: 400));

      final ring = tester.state(find.byType(TimerProgressRing)) as dynamic;
      expect(ring.secondStartedAtForTest, isNotNull,
          reason: 'the running arc has marked where it is in the second');

      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      expect(
        ring.secondStartedAtForTest,
        isNull,
        reason: 'a stale mark is what lets the arc jump on resume',
      );
    });
  });

  group('the percentage and the arc', () {
    // The bug: the readout computed its percentage from whole seconds while
    // the arc drew a continuous value, so the text could still read 99% at the
    // moment the ring visually closed the loop. The ring now hands the figure
    // to whatever it draws inside itself.
    testWidgets('come from the same value', (tester) async {
      late int reported;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppTheme.dark]),
          home: Scaffold(
            body: TimerProgressRing(
              elapsedSeconds: 1500,
              targetMinutes: 50,
              timerState: TimerState.paused,
              childBuilder: (context, progressPercentage) {
                reported = progressPercentage;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(reported, (painter(tester).progress * 100).toInt());
      expect(reported, 50);
    });

    testWidgets('reach 100 exactly when the arc is full', (tester) async {
      late int reported;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppTheme.dark]),
          home: Scaffold(
            body: TimerProgressRing(
              elapsedSeconds: 3000,
              targetMinutes: 50,
              timerState: TimerState.completed,
              childBuilder: (context, progressPercentage) {
                reported = progressPercentage;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(painter(tester).progress, 1.0);
      expect(reported, 100);
    });
  });

  testWidgets('the readout holds still while the ring breathes',
      (tester) async {
    // Only the ring moves. Text that changes size pulls the eye hard, which
    // is the last thing wanted during a fifty-minute session.
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(extensions: const [AppTheme.dark]),
        home: Scaffold(
          body: Center(
            child: TimerProgressRing(
              elapsedSeconds: 66,
              targetMinutes: 60,
              timerState: TimerState.running,
              childBuilder: (context, progressPercentage) => TimerDisplay(
                remainingSeconds: 3534,
                phaseLabel: 'Focus',
                progressPercentage: progressPercentage,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final first = tester.getRect(find.text('58:54'));
    await tester.pump(const Duration(milliseconds: 900));
    final second = tester.getRect(find.text('58:54'));

    expect(second, first, reason: 'the digits must not scale with the ring');
  });

  testWidgets('the ring is thinner than the goal-details circle',
      (tester) async {
    // 16pt belongs around a 192px statistics circle, not around a timer.
    await pump(tester, state: TimerState.paused);

    expect(
      painter(tester).strokeWidth,
      lessThan(CircularProgressPainter.defaultStrokeWidth),
    );
  });
}
