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
}
