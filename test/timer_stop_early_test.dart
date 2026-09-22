import 'package:deadly/models/study_session.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stopping a session early is not the same as finishing it.
///
/// The bug: pressing Stop five minutes into a sixty-minute session wrote the
/// session as completed with elapsedSeconds reset to zero. Reopening it began
/// from scratch, the remaining fifty-five minutes were unrecoverable, and the
/// session counted toward the streak.
///
/// It also contradicted the rest of the app, which decides a session is done
/// by comparing actualDuration against the planned duration
/// (home_screen.dart:56), not by reading isCompleted.
///
/// These call StudySession.stoppedAfter and .resumeFrom directly -- the same
/// methods the timer screen uses. An earlier version of this file re-created
/// that logic locally, and stayed green when the original bug was restored in
/// the screen: it was testing its own copy, not the code that ships.
void main() {
  StudySession planned({int durationMinutes = 60}) => StudySession(
        id: 's1',
        goalId: 'g1',
        date: DateTime(2026, 9, 16),
        duration: durationMinutes,
        startTime: DateTime(2026, 9, 16, 14),
      );

  StudySession stoppedAt(
    StudySession session, {
    required int elapsedSeconds,
  }) =>
      session.stoppedAfter(elapsedSeconds);

  group('stopping early', () {
    test('keeps the elapsed time so the session can resume', () {
      final saved = stoppedAt(planned(), elapsedSeconds: 300);

      expect(
        saved.elapsedSeconds,
        300,
        reason: 'resuming must open on the second it was left at',
      );
    });

    test('does not mark the session finished', () {
      final saved = stoppedAt(planned(), elapsedSeconds: 300);

      expect(saved.isCompleted, isFalse);
      expect(saved.completedAt, isNull);
    });

    test('records what was actually studied', () {
      final saved = stoppedAt(planned(), elapsedSeconds: 300);

      expect(saved.actualDuration, 5);
    });

    test('stays unfinished by the rule the rest of the app uses', () {
      // home_screen.dart:56 — actualDuration >= duration.
      final saved = stoppedAt(planned(), elapsedSeconds: 300);

      expect(saved.actualDuration! >= saved.duration, isFalse);
    });

    test('a session resumed and stopped early loses its completion', () {
      // copyWith could not express this: `completedAt ?? this.completedAt`
      // keeps the old timestamp, so the session would still look finished.
      final finished = StudySession(
        id: 's1',
        goalId: 'g1',
        date: DateTime(2026, 9, 16),
        duration: 60,
        isCompleted: true,
        actualDuration: 60,
        completedAt: DateTime(2026, 9, 15, 12),
      );

      final saved = stoppedAt(finished, elapsedSeconds: 300);

      expect(saved.completedAt, isNull);
      expect(saved.isCompleted, isFalse);
    });
  });

  group('stopping at the end', () {
    test('marks the session finished', () {
      final saved = stoppedAt(planned(), elapsedSeconds: 3600);

      expect(saved.isCompleted, isTrue);
      expect(saved.completedAt, isNotNull);
    });

    test('resets elapsed so it does not reopen at zero remaining', () {
      // A finished session reopening at 00:00 offers nothing but Restart.
      final saved = stoppedAt(planned(), elapsedSeconds: 3600);

      expect(saved.elapsedSeconds, 0);
    });

    test('overtime still counts as finished', () {
      final saved = stoppedAt(planned(), elapsedSeconds: 3900);

      expect(saved.isCompleted, isTrue);
      expect(saved.actualDuration, 65);
    });
  });

  group('reopening', () {
    int restoredElapsed(StudySession session) => session.resumeFrom;

    test('an interrupted session opens where it was left', () {
      final saved = stoppedAt(planned(), elapsedSeconds: 300);

      expect(restoredElapsed(saved), 300);
    });

    test('a finished session opens fresh', () {
      final saved = stoppedAt(planned(), elapsedSeconds: 3600);

      expect(restoredElapsed(saved), 0);
    });

    test('a completed session with leftover elapsed still opens fresh', () {
      // The other two completion paths (_handleBack and _completeSession) do
      // not zero elapsedSeconds, so this is the case the isCompleted check in
      // resumeFrom actually protects. Without it, a finished session would
      // reopen mid-countdown.
      final finished = StudySession(
        id: 's1',
        goalId: 'g1',
        date: DateTime(2026, 9, 16),
        duration: 60,
        isCompleted: true,
        elapsedSeconds: 1800,
        actualDuration: 60,
        completedAt: DateTime(2026, 9, 16, 15),
      );

      expect(restoredElapsed(finished), 0);
    });
  });

  group('logged time never shrinks', () {
    // The bug: actualDuration was assigned, not accumulated. A session stopped
    // at 40 minutes, reopened and stopped again a minute later, was written as
    // having studied 1 minute -- the first 40 were gone.
    test('a shorter second run does not erase the first', () {
      final firstStop = stoppedAt(planned(), elapsedSeconds: 40 * 60);
      expect(firstStop.actualDuration, 40);

      // Reopened and stopped again after only a minute on a fresh clock.
      final secondStop = firstStop.stoppedAfter(60);

      expect(
        secondStop.actualDuration,
        40,
        reason: 'the 40 minutes already logged must survive',
      );
    });

    test('a longer second run replaces the first', () {
      final firstStop = stoppedAt(planned(), elapsedSeconds: 40 * 60);
      // Resumed from 40 minutes and carried on to 50.
      final secondStop = firstStop.stoppedAfter(50 * 60);

      expect(secondStop.actualDuration, 50);
    });
  });

  group('marking complete by hand', () {
    test('credits at least the planned duration', () {
      final saved = planned().markedComplete(300);

      expect(saved.actualDuration, 60);
      expect(saved.isCompleted, isTrue);
      expect(saved.completedAt, isNotNull);
    });

    test('keeps overtime rather than clamping to the plan', () {
      // The bug: _handleBack and _completeSession both wrote
      // `actualDuration: duration`, so a 65 minute run was logged as 60.
      final saved = planned().markedComplete(3900);

      expect(saved.actualDuration, 65);
    });

    test('never clamps away time logged on an earlier run', () {
      final partly = stoppedAt(planned(durationMinutes: 120), elapsedSeconds: 90 * 60);
      expect(partly.actualDuration, 90);

      // Reopened, and marked complete straight away on a fresh clock.
      final saved = partly.markedComplete(0);

      expect(
        saved.actualDuration,
        120,
        reason: 'marking complete means the session was done',
      );
    });

    test('resets elapsed so it reopens on a clean timer', () {
      final saved = planned().markedComplete(1800);

      expect(saved.elapsedSeconds, 0);
      expect(saved.resumeFrom, 0);
    });
  });

  group('substantially studied sessions count as done', () {
    test('stopping just short of the target still counts', () {
      // 58 of 60 minutes. Demanding the last two would cost the user the day.
      final saved = stoppedAt(planned(), elapsedSeconds: 58 * 60);

      expect(saved.isCompleted, isFalse,
          reason: 'the session stays resumable');
      expect(saved.isEffectivelyStudied, isTrue);
    });

    test('stopping early does not count', () {
      final saved = stoppedAt(planned(), elapsedSeconds: 300);

      expect(saved.isEffectivelyStudied, isFalse);
    });

    test('a finished session counts', () {
      final saved = stoppedAt(planned(), elapsedSeconds: 3600);

      expect(saved.isEffectivelyStudied, isTrue);
    });

    test('a legacy session with no actualDuration falls back to isCompleted', () {
      final legacy = StudySession(
        id: 's1',
        goalId: 'g1',
        date: DateTime(2026, 9, 16),
        duration: 60,
        isCompleted: true,
      );

      expect(legacy.studiedMinutes, 60);
      expect(legacy.isEffectivelyStudied, isTrue);
    });

    test('an untouched planned session does not count', () {
      // As the two real creation sites build one -- auto_planner_service.dart
      // and study_session_picker_modal.dart both pass isCompleted: false. The
      // constructor's default is true, which is why they have to.
      final untouched = StudySession(
        id: 's1',
        goalId: 'g1',
        date: DateTime(2026, 9, 16),
        duration: 60,
        isCompleted: false,
      );

      expect(untouched.studiedMinutes, 0);
      expect(untouched.isEffectivelyStudied, isFalse);
    });
  });
}
