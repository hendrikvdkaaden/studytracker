import 'package:deadly/models/goal.dart';
import 'package:deadly/models/study_session.dart';
import 'package:deadly/services/calendar_event_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 8, 20, 14, 30);

Goal _goal({
  required DateTime date,
  bool isCompleted = false,
  String subject = 'Math',
}) {
  return Goal(
    id: 'goal-1',
    title: 'Chapter 5 Exam',
    subject: subject,
    date: date,
    type: GoalType.exam,
    isCompleted: isCompleted,
    studyTime: 120,
  );
}

StudySession _session({
  required DateTime date,
  DateTime? startTime,
  int duration = 90,
  bool isCompleted = false,
}) {
  return StudySession(
    id: 'session-1',
    goalId: 'goal-1',
    date: date,
    duration: duration,
    isCompleted: isCompleted,
    startTime: startTime,
  );
}

void main() {
  group('session timing', () {
    test('uses the session start time when one is set', () {
      final start = DateTime(2026, 8, 21, 14, 0);
      final s = _session(date: DateTime(2026, 8, 21), startTime: start);

      expect(CalendarEventMapper.sessionStart(s), start);
    });

    test('falls back to 09:00 when no start time was picked', () {
      final s = _session(date: DateTime(2026, 8, 21), startTime: null);

      expect(
        CalendarEventMapper.sessionStart(s),
        DateTime(2026, 8, 21, 9),
        reason: 'must match the fallback NotificationService uses',
      );
    });

    test('ends after the planned duration', () {
      final s = _session(
        date: DateTime(2026, 8, 21),
        startTime: DateTime(2026, 8, 21, 14, 0),
        duration: 90,
      );

      expect(CalendarEventMapper.sessionEnd(s), DateTime(2026, 8, 21, 15, 30));
    });

    test('a duration crossing midnight still ends correctly', () {
      final s = _session(
        date: DateTime(2026, 8, 21),
        startTime: DateTime(2026, 8, 21, 23, 30),
        duration: 60,
      );

      expect(CalendarEventMapper.sessionEnd(s), DateTime(2026, 8, 22, 0, 30));
    });
  });

  group('deadline timing', () {
    test('spans the whole day regardless of the time of day', () {
      final g = _goal(date: DateTime(2026, 8, 25, 12, 0));

      expect(CalendarEventMapper.deadlineStart(g), DateTime(2026, 8, 25));
      expect(CalendarEventMapper.deadlineEnd(g), DateTime(2026, 8, 26));
    });
  });

  group('what gets synced when sync is switched on', () {
    test('includes a future unfinished deadline', () {
      final g = _goal(date: DateTime(2026, 8, 25));

      expect(CalendarEventMapper.shouldSyncGoal(g, _now), isTrue);
    });

    test('includes something due later today', () {
      // Deadline at noon, "now" is 14:30 — same day still counts, matching
      // how the app treats today's deadlines as upcoming rather than past.
      final g = _goal(date: DateTime(2026, 8, 20, 12, 0));

      expect(CalendarEventMapper.shouldSyncGoal(g, _now), isTrue);
    });

    test('skips a past deadline', () {
      final g = _goal(date: DateTime(2026, 8, 19));

      expect(CalendarEventMapper.shouldSyncGoal(g, _now), isFalse);
    });

    test('skips a completed deadline even when it is still ahead', () {
      final g = _goal(date: DateTime(2026, 8, 25), isCompleted: true);

      expect(CalendarEventMapper.shouldSyncGoal(g, _now), isFalse);
    });

    test('includes a future unfinished session', () {
      final s = _session(date: DateTime(2026, 8, 22));

      expect(CalendarEventMapper.shouldSyncSession(s, _now), isTrue);
    });

    test('skips a session already completed', () {
      final s = _session(date: DateTime(2026, 8, 22), isCompleted: true);

      expect(CalendarEventMapper.shouldSyncSession(s, _now), isFalse);
    });

    test('skips a session from a past day', () {
      final s = _session(date: DateTime(2026, 8, 18));

      expect(CalendarEventMapper.shouldSyncSession(s, _now), isFalse);
    });
  });

  group('session description', () {
    test('carries the note the user wrote', () {
      expect(
        CalendarEventMapper.sessionDescription('Revise chapter 5'),
        'Revise chapter 5',
      );
    });

    test('trims surrounding whitespace', () {
      expect(
        CalendarEventMapper.sessionDescription('  Revise chapter 5  '),
        'Revise chapter 5',
      );
    });

    test('returns null when there is no note', () {
      expect(CalendarEventMapper.sessionDescription(null), isNull);
      expect(
        CalendarEventMapper.sessionDescription('   '),
        isNull,
        reason: 'a blank note must not leave an empty notes field behind',
      );
    });
  });

  group('titles', () {
    test('marks sessions and deadlines distinctly', () {
      expect(CalendarEventMapper.sessionTitle('Chapter 5 Exam', 'Math'),
          'Study Math: Chapter 5 Exam');
      expect(CalendarEventMapper.deadlineTitle(_goal(date: _now)),
          'Deadline Math: Chapter 5 Exam');
    });

    test('a session without a subject keeps a plain title', () {
      expect(
        CalendarEventMapper.sessionTitle('Chapter 5 Exam', ''),
        'Study: Chapter 5 Exam',
        reason: 'an empty subject must not leave a dangling separator',
      );
      expect(
        CalendarEventMapper.sessionTitle('Chapter 5 Exam', '   '),
        'Study: Chapter 5 Exam',
      );
    });

    test('a deadline without a subject keeps a plain title', () {
      expect(
        CalendarEventMapper.deadlineTitle(_goal(date: _now, subject: '')),
        'Deadline: Chapter 5 Exam',
        reason: 'an empty subject must not leave a dangling separator',
      );
      expect(
        CalendarEventMapper.deadlineTitle(_goal(date: _now, subject: '   ')),
        'Deadline: Chapter 5 Exam',
      );
    });
  });
}
