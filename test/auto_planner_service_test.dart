import 'package:deadly/models/study_session.dart';
import 'package:deadly/services/auto_planner_service.dart';
import 'package:flutter_test/flutter_test.dart';

StudySession _sessionAt(DateTime start, {int duration = 60}) {
  return StudySession(
    id: 'existing-${start.toIso8601String()}',
    goalId: 'goal-1',
    date: DateTime(start.year, start.month, start.day),
    duration: duration,
    startTime: start,
  );
}

/// Two sessions overlap when one starts before the other ends.
bool _overlaps(StudySession a, StudySession b) {
  final aEnd = a.startTime!.add(Duration(minutes: a.duration));
  final bEnd = b.startTime!.add(Duration(minutes: b.duration));
  return a.startTime!.isBefore(bEnd) && aEnd.isAfter(b.startTime!);
}

void main() {
  // A fixed window well clear of "today" so the planner always has days to use.
  final deadline = DateTime.now().add(const Duration(days: 14));

  List<StudySession> generate({
    required List<StudySession> existing,
    int totalMinutes = 240,
    List<BusyBlock> busy = const [],
  }) {
    return AutoPlannerService.generateSessions(
      goalId: 'goal-1',
      deadline: deadline,
      totalMinutes: totalMinutes,
      weekdays: const [1, 2, 3, 4, 5, 6, 7],
      startHour: 9,
      startMinute: 0,
      endHour: 17,
      endMinute: 0,
      sessionDuration: 60,
      breakMinutes: 0,
      existingSessions: existing,
      busyBlocks: busy,
    );
  }

  group('generateSessions', () {
    test('plans around an existing session instead of overlapping it', () {
      // Regression: sessions the user planned by hand were being scheduled
      // straight over, because the planner never saw them.
      final busyDay = deadline.subtract(const Duration(days: 3));
      final existing = [
        _sessionAt(DateTime(busyDay.year, busyDay.month, busyDay.day, 9, 0)),
        _sessionAt(DateTime(busyDay.year, busyDay.month, busyDay.day, 10, 0)),
      ];

      final generated = generate(existing: existing);

      expect(generated, isNotEmpty);
      for (final g in generated) {
        for (final e in existing) {
          expect(_overlaps(g, e), isFalse,
              reason: 'generated ${g.startTime} overlaps existing ${e.startTime}');
        }
      }
    });

    test('generated sessions do not overlap each other', () {
      final generated = generate(existing: const [], totalMinutes: 480);

      for (var i = 0; i < generated.length; i++) {
        for (var j = i + 1; j < generated.length; j++) {
          expect(_overlaps(generated[i], generated[j]), isFalse,
              reason: 'two generated sessions overlap');
        }
      }
    });

    test('returns nothing when every slot is already taken', () {
      // Fill the whole 09:00-17:00 window on every remaining day.
      final existing = <StudySession>[];
      for (var d = 1; d <= 14; d++) {
        final day = DateTime.now().add(Duration(days: d));
        for (var h = 9; h < 17; h++) {
          existing.add(_sessionAt(DateTime(day.year, day.month, day.day, h, 0)));
        }
      }

      expect(generate(existing: existing), isEmpty);
    });

    test('schedules nothing for a zero or negative study time', () {
      expect(generate(existing: const [], totalMinutes: 0), isEmpty);
    });
  });

  group('planning around the calendar', () {
    /// A block on the first day the planner will use, so it is always hit.
    BusyBlock blockOnFirstDay(int fromHour, int toHour) {
      final day = DateTime.now().add(const Duration(days: 1));
      return BusyBlock(
        DateTime(day.year, day.month, day.day, fromHour),
        DateTime(day.year, day.month, day.day, toHour),
      );
    }

    test('leaves an appointment alone', () {
      final busy = blockOnFirstDay(9, 10);

      final sessions = generate(existing: const [], busy: [busy]);

      expect(sessions, isNotEmpty);
      for (final s in sessions) {
        final end = s.startTime!.add(Duration(minutes: s.duration));
        expect(
          s.startTime!.isBefore(busy.end) && end.isAfter(busy.start),
          isFalse,
          reason: '$s was planned over the appointment',
        );
      }
    });

    test('a full day pushes its sessions to other days', () {
      final blocked = blockOnFirstDay(9, 17);

      final sessions = generate(existing: const [], busy: [blocked]);

      expect(sessions, isNotEmpty);
      expect(
        sessions.where((s) => s.date.day == blocked.start.day),
        isEmpty,
        reason: 'the whole study window that day is taken',
      );
    });

    test('an appointment outside the study window changes nothing', () {
      final evening = blockOnFirstDay(20, 22);

      expect(
        generate(existing: const [], busy: [evening]).length,
        generate(existing: const []).length,
      );
    });

    test('appointments and existing sessions are both respected', () {
      final day = DateTime.now().add(const Duration(days: 1));
      final session = _sessionAt(DateTime(day.year, day.month, day.day, 9));
      final busy = blockOnFirstDay(10, 11);

      final sessions = generate(existing: [session], busy: [busy]);

      for (final s in sessions) {
        expect(_overlaps(s, session), isFalse);
        final end = s.startTime!.add(Duration(minutes: s.duration));
        expect(s.startTime!.isBefore(busy.end) && end.isAfter(busy.start),
            isFalse);
      }
    });

    test('passing no blocks is the same as passing none at all', () {
      expect(
        generate(existing: const [], busy: const []).length,
        generate(existing: const []).length,
      );
    });

    test('a calendar that blocks everything gives up rather than hanging', () {
      // Every study window between tomorrow and the deadline is taken. The
      // planner must run out of slots and return, not spin looking for one.
      final blocks = <BusyBlock>[];
      for (var i = 1; i <= 15; i++) {
        final day = DateTime.now().add(Duration(days: i));
        blocks.add(BusyBlock(
          DateTime(day.year, day.month, day.day, 9),
          DateTime(day.year, day.month, day.day, 17),
        ));
      }

      expect(generate(existing: const [], busy: blocks), isEmpty);
    }, timeout: const Timeout(Duration(seconds: 5)));
  });
}
