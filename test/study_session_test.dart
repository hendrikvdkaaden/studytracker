import 'package:deadly/models/study_session.dart';
import 'package:flutter_test/flutter_test.dart';

StudySession _planned({int duration = 45}) {
  return StudySession(
    id: 'session-1',
    goalId: 'goal-1',
    date: DateTime(2026, 8, 10),
    duration: duration,
    // Note: the model defaults isCompleted to true, so a planned session has
    // to say so explicitly.
    isCompleted: false,
    startTime: DateTime(2026, 8, 10, 9, 0),
  );
}

/// Mirrors what the timer screen writes when the user taps "mark as complete"
/// before the countdown has finished.
StudySession _markedComplete(StudySession s) {
  return s.copyWith(
    actualDuration: s.duration,
    elapsedSeconds: 0,
    isCompleted: true,
    completedAt: DateTime(2026, 8, 10, 9, 20),
  );
}

void main() {
  group('marking a session complete', () {
    test('logs the full planned duration as study time', () {
      final done = _markedComplete(_planned(duration: 45));

      expect(done.actualDuration, 45);
      expect(done.isCompleted, isTrue);
      expect(done.completedAt, isNotNull);
    });

    test('resets elapsedSeconds so the timer reopens at full time', () {
      // Regression: elapsedSeconds used to be set to the full target, so
      // reopening the session showed a timer already at 00:00 with only a
      // "Restart" button — which then fired the completion confetti again.
      final done = _markedComplete(_planned(duration: 45));

      expect(done.elapsedSeconds, 0,
          reason: 'a completed session must not resume a spent timer');
    });

    test('an unfinished session keeps its elapsed time for resuming', () {
      final inProgress = _planned().copyWith(elapsedSeconds: 600);

      expect(inProgress.isCompleted, isFalse);
      expect(inProgress.elapsedSeconds, 600);
    });
  });

  group('editing a session', () {
    // The session editor used to rebuild StudySession from scratch, which
    // silently dropped every field the form does not show -- including the
    // calendar event id, orphaning the entry already in the user's calendar.
    test('carries the calendar event id through an edit', () {
      final session = _planned().copyWith(calendarEventId: 'event-1');

      final edited = session.copyWith(
        date: DateTime(2026, 8, 11),
        duration: 60,
        startTime: DateTime(2026, 8, 11, 14, 0),
      );

      expect(edited.calendarEventId, 'event-1');
      expect(edited.duration, 60);
      expect(edited.date, DateTime(2026, 8, 11));
    });

    test('carries the timer run state through an edit', () {
      final session = _planned().copyWith(elapsedSeconds: 300);

      final edited = session.copyWith(duration: 60);

      expect(edited.elapsedSeconds, 300);
    });

    // Documents why the editor assigns notes directly instead of through
    // copyWith: a cleared note would otherwise survive the edit.
    test('copyWith cannot clear a field', () {
      final session = _planned().copyWith(notes: 'chapter 4');

      final cleared = session.copyWith(notes: null);

      expect(cleared.notes, 'chapter 4');
    });
  });
}
