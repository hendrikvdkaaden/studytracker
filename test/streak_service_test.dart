import 'package:deadly/models/study_session.dart';
import 'package:deadly/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fixed "now" so the tests do not depend on the day they run.
final _now = DateTime(2026, 8, 10, 14, 30);

DateTime _daysAgo(int days) =>
    DateTime(_now.year, _now.month, _now.day - days);

/// A session planned [daysAgo] days back. Completed sessions are marked done
/// on their own day, which is what counts as "on time".
StudySession _session({
  required int daysAgo,
  required bool completed,
  String suffix = '',
}) {
  final day = _daysAgo(daysAgo);
  return StudySession(
    id: 'session-$daysAgo$suffix',
    goalId: 'goal-1',
    date: day,
    duration: 60,
    isCompleted: completed,
    startTime: DateTime(day.year, day.month, day.day, 9, 0),
    completedAt:
        completed ? DateTime(day.year, day.month, day.day, 10, 0) : null,
  );
}

int _streak(List<StudySession> sessions) =>
    StreakService.calculateStreak(sessions: sessions, now: _now);

void main() {
  group('calculateStreak', () {
    test('counts today plus the two days before it', () {
      final streak = _streak([
        _session(daysAgo: 2, completed: true),
        _session(daysAgo: 1, completed: true),
        _session(daysAgo: 0, completed: true),
      ]);

      expect(streak, 3);
    });

    test('keeps the streak alive while today is still in progress', () {
      // Regression: today's unfinished sessions used to stop the scan, so the
      // streak collapsed to 0 and the badge never appeared.
      final streak = _streak([
        _session(daysAgo: 2, completed: true),
        _session(daysAgo: 1, completed: true),
        _session(daysAgo: 0, completed: false),
      ]);

      expect(streak, 2,
          reason: 'days already earned stay counted until the day is over');
    });

    test('an elapsed day with unfinished sessions breaks the streak', () {
      final streak = _streak([
        _session(daysAgo: 3, completed: true),
        _session(daysAgo: 2, completed: false),
        _session(daysAgo: 1, completed: true),
        _session(daysAgo: 0, completed: true),
      ]);

      expect(streak, 2, reason: 'counting stops at the missed day');
    });

    test('a day without planned sessions does not break the streak', () {
      // Nothing planned 2 days ago — the gap should be skipped, not counted.
      final streak = _streak([
        _session(daysAgo: 3, completed: true),
        _session(daysAgo: 1, completed: true),
        _session(daysAgo: 0, completed: true),
      ]);

      expect(streak, 3);
    });

    test('every session on a day must be done for it to count', () {
      final streak = _streak([
        _session(daysAgo: 1, completed: true),
        _session(daysAgo: 1, completed: false, suffix: '-b'),
        _session(daysAgo: 0, completed: true),
      ]);

      expect(streak, 1, reason: 'yesterday was only half finished');
    });

    test('counts days finished ahead of schedule', () {
      // Three days planned, but the user powered through all of them on the
      // first day. Finishing early is still finishing on time, so every day
      // counts.
      final earlyFinish = DateTime(
        _daysAgo(2).year,
        _daysAgo(2).month,
        _daysAgo(2).day,
        20,
      );
      final sessions = [
        for (var d = 2; d >= 0; d--)
          StudySession(
            id: 'ahead-$d',
            goalId: 'goal-1',
            date: _daysAgo(d),
            duration: 60,
            isCompleted: true,
            startTime: DateTime(
                _daysAgo(d).year, _daysAgo(d).month, _daysAgo(d).day, 9),
            completedAt: earlyFinish,
          ),
      ];

      expect(_streak(sessions), 3);
    });

    test('a session finished after its day does not count', () {
      final day = _daysAgo(1);
      final finishedNextDay = StudySession(
        id: 'late',
        goalId: 'goal-1',
        date: day,
        duration: 60,
        isCompleted: true,
        startTime: DateTime(day.year, day.month, day.day, 9),
        // Completed a day late.
        completedAt: DateTime(_now.year, _now.month, _now.day, 10),
      );

      expect(StreakService.isCompletedOnTime(finishedNextDay), isFalse);
      expect(_streak([finishedNextDay, _session(daysAgo: 0, completed: true)]), 1,
          reason: 'the late day breaks the streak, today still counts');
    });

    test('returns 0 without any sessions', () {
      expect(_streak([]), 0);
    });

    test('a single completed day stays below the badge threshold', () {
      expect(_streak([_session(daysAgo: 0, completed: true)]), 1);
    });
  });

  group('frozen days', () {
    test('a frozen day bridges instead of breaking the streak', () {
      // Missed two days ago, but a freeze was spent there: the days on either
      // side still join up.
      final sessions = [
        _session(daysAgo: 0, completed: true),
        _session(daysAgo: 1, completed: true),
        _session(daysAgo: 2, completed: false),
        _session(daysAgo: 3, completed: true),
      ];

      expect(
        StreakService.calculateStreak(
          sessions: sessions,
          now: _now,
          frozenDays: {_daysAgo(2)},
        ),
        3,
        reason: 'the three studied days count; the frozen one only bridges',
      );
    });

    test('a frozen day does not extend the streak on its own', () {
      // Nothing was studied; a freeze must not manufacture a streak.
      final sessions = [_session(daysAgo: 1, completed: false)];

      expect(
        StreakService.calculateStreak(
          sessions: sessions,
          now: _now,
          frozenDays: {_daysAgo(1)},
        ),
        0,
      );
    });

    test('an unfrozen missed day still breaks it', () {
      final sessions = [
        _session(daysAgo: 0, completed: true),
        _session(daysAgo: 1, completed: false),
        _session(daysAgo: 2, completed: true),
      ];

      expect(
        StreakService.calculateStreak(
          sessions: sessions,
          now: _now,
          frozenDays: {_daysAgo(5)},
        ),
        1,
        reason: 'freezing an unrelated day must not rescue this one',
      );
    });

    test('two missed days with only one frozen still break the streak', () {
      final sessions = [
        _session(daysAgo: 1, completed: false),
        _session(daysAgo: 2, completed: false),
        _session(daysAgo: 3, completed: true),
      ];

      expect(
        StreakService.calculateStreak(
          sessions: sessions,
          now: _now,
          frozenDays: {_daysAgo(1)},
        ),
        0,
        reason: 'the second gap is not covered, so the chain ends there',
      );
    });

    test('omitting frozenDays keeps the old behaviour', () {
      // The default must be inert, or every existing caller changes meaning.
      final sessions = [
        _session(daysAgo: 1, completed: false),
        _session(daysAgo: 2, completed: true),
      ];

      expect(
        StreakService.calculateStreak(sessions: sessions, now: _now),
        0,
      );
    });
  });
}
