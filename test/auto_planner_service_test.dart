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
}
