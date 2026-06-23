import 'package:uuid/uuid.dart';
import '../models/study_session.dart';

class AutoPlannerService {
  static List<StudySession> generateSessions({
    required String goalId,
    required DateTime deadline,
    required int totalMinutes,
    required List<int> weekdays,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required int sessionDuration,
    required int breakMinutes,
    required List<StudySession> existingSessions,
  }) {
    if (sessionDuration <= 0 || weekdays.isEmpty || totalMinutes <= 0) {
      return [];
    }

    final windowMinutes =
        (endHour * 60 + endMinute) - (startHour * 60 + startMinute);
    if (windowMinutes <= 0 || sessionDuration > windowMinutes) return [];

    // Each session slot = session + break (except the last one of the day)
    // Max sessions per day: how many (session + break) blocks fit, +1 for the last session without break
    final slotMinutes = sessionDuration + breakMinutes;
    final sessionsPerDayMax = breakMinutes == 0
        ? windowMinutes ~/ sessionDuration
        : (windowMinutes - sessionDuration) ~/ slotMinutes + 1;

    // Collect all available days between tomorrow and deadline
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
    final availableDays = <DateTime>[];
    var current = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).add(const Duration(days: 1));

    while (!current.isAfter(deadlineDay)) {
      if (weekdays.contains(current.weekday)) availableDays.add(current);
      current = current.add(const Duration(days: 1));
    }

    if (availableDays.isEmpty) return [];

    // Track how many sessions are already planned per day slot
    // sessionsPerDay[dayIndex] = number of sessions already placed that day
    final sessionsPerDay = List<int>.filled(availableDays.length, 0);

    final allSessions = List<StudySession>.from(existingSessions);
    final result = <StudySession>[];
    int minutesRemaining = totalMinutes;

    final endMinutes = endHour * 60 + endMinute;

    bool addedAny = true;
    while (minutesRemaining > 0 && addedAny) {
      addedAny = false;
      for (int i = 0; i < availableDays.length && minutesRemaining > 0; i++) {
        if (sessionsPerDay[i] >= sessionsPerDayMax) continue;

        final day = availableDays[i];
        final slotStartMinutes =
            startHour * 60 + startMinute + sessionsPerDay[i] * slotMinutes;

        // Guard: slot must end within the study window
        if (slotStartMinutes + sessionDuration > endMinutes) {
          sessionsPerDay[i] = sessionsPerDayMax; // mark day as full
          continue;
        }

        final slotStart = DateTime(
          day.year,
          day.month,
          day.day,
          slotStartMinutes ~/ 60,
          slotStartMinutes % 60,
        );

        if (!_hasOverlap(slotStart, sessionDuration, allSessions)) {
          final session = StudySession(
            id: const Uuid().v4(),
            goalId: goalId,
            date: day,
            duration: sessionDuration,
            isCompleted: false,
            startTime: slotStart,
          );
          result.add(session);
          allSessions.add(session);
          sessionsPerDay[i]++;
          minutesRemaining -= sessionDuration;
          addedAny = true;
        } else {
          // Slot is blocked by an external session — advance to next slot for this day
          sessionsPerDay[i]++;
        }
      }
    }

    return result;
  }

  static bool _hasOverlap(
    DateTime start,
    int duration,
    List<StudySession> existing,
  ) {
    final end = start.add(Duration(minutes: duration));
    for (final s in existing) {
      if (s.startTime == null) continue;
      final sEnd = s.startTime!.add(Duration(minutes: s.duration));
      if (start.isBefore(sEnd) && end.isAfter(s.startTime!)) return true;
    }
    return false;
  }
}
