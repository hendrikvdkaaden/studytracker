import 'package:deadly/models/study_session.dart';
import 'package:deadly/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// An early stop must not silently cost the user their streak.
///
/// The bug: stopping the timer leaves the session open (isCompleted false,
/// completedAt null) so it can be resumed. calculateStreak required every
/// session that day to be completed on time, and today is exempt from the
/// scan -- so studying 58 of 60 planned minutes looked fine that evening and
/// the streak was simply gone the next morning, with no way to recover it.
void main() {
  StudySession session({
    required DateTime day,
    int duration = 60,
    int? actualDuration,
    bool isCompleted = false,
    DateTime? completedAt,
  }) =>
      StudySession(
        id: '${day.toIso8601String()}-$actualDuration',
        goalId: 'g1',
        date: day,
        duration: duration,
        isCompleted: isCompleted,
        actualDuration: actualDuration,
        completedAt: completedAt,
      );

  final now = DateTime(2026, 9, 22, 20);
  DateTime daysAgo(int n) => DateTime(2026, 9, 22 - n);

  group('a session stopped near the end', () {
    test('counts as completed on time', () {
      final almost = session(day: daysAgo(1), actualDuration: 58);

      expect(StreakService.isCompletedOnTime(almost), isTrue);
    });

    test('is not counted as missed', () {
      final almost = session(day: daysAgo(1), actualDuration: 58);

      expect(StreakService.isMissed(almost, now), isFalse);
    });

    test('does not break the streak overnight', () {
      final sessions = [
        session(day: daysAgo(2), actualDuration: 60, isCompleted: true),
        // Stopped two minutes short, yesterday. Still open, still resumable.
        session(day: daysAgo(1), actualDuration: 58),
        session(day: daysAgo(0), actualDuration: 60, isCompleted: true),
      ];

      expect(
        StreakService.calculateStreak(sessions: sessions, now: now),
        3,
        reason: 'the near-miss day must still count',
      );
    });
  });

  group('a session genuinely abandoned', () {
    test('does not count as completed on time', () {
      final abandoned = session(day: daysAgo(1), actualDuration: 5);

      expect(StreakService.isCompletedOnTime(abandoned), isFalse);
    });

    test('is counted as missed once its day is over', () {
      final abandoned = session(day: daysAgo(1), actualDuration: 5);

      expect(StreakService.isMissed(abandoned, now), isTrue);
    });

    test('breaks the streak', () {
      final sessions = [
        session(day: daysAgo(2), actualDuration: 60, isCompleted: true),
        // Five minutes of a sixty minute session is not a study day.
        session(day: daysAgo(1), actualDuration: 5),
        session(day: daysAgo(0), actualDuration: 60, isCompleted: true),
      ];

      expect(
        StreakService.calculateStreak(sessions: sessions, now: now),
        1,
        reason: 'only today survives; yesterday breaks it',
      );
    });
  });

  test('a late completion still does not count', () {
    // The existing rule is untouched: completedAt after the planned day is a
    // miss regardless of how much was studied.
    final late = session(
      day: daysAgo(2),
      actualDuration: 60,
      isCompleted: true,
      completedAt: daysAgo(0),
    );

    expect(StreakService.isCompletedOnTime(late), isFalse);
  });
}
