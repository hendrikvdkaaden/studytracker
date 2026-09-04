import 'package:uuid/uuid.dart';
import '../models/study_session.dart';

/// A stretch of time the planner may not schedule into.
///
/// Half-open: a block ending at 10:00 leaves 10:00 itself free.
class BusyBlock {
  final DateTime start;
  final DateTime end;

  const BusyBlock(this.start, this.end);

  bool overlaps(DateTime otherStart, DateTime otherEnd) =>
      otherStart.isBefore(end) && otherEnd.isAfter(start);

  @override
  String toString() => 'BusyBlock($start -> $end)';
}

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

    /// Times the user is already occupied, typically their calendar. Empty by
    /// default so callers that do not read the calendar are unaffected.
    List<BusyBlock> busyBlocks = const [],
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

    // Sessions and calendar entries are the same thing to the planner: time
    // that is taken. Converting once up front keeps the overlap check to a
    // single concept.
    final blocked = <BusyBlock>[
      ...busyBlocks,
      for (final s in existingSessions)
        if (s.startTime != null)
          BusyBlock(s.startTime!, s.startTime!.add(Duration(minutes: s.duration))),
    ];
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

        if (!_hasOverlap(slotStart, sessionDuration, blocked)) {
          final session = StudySession(
            id: const Uuid().v4(),
            goalId: goalId,
            date: day,
            duration: sessionDuration,
            isCompleted: false,
            startTime: slotStart,
          );
          result.add(session);
          // Generated sessions block each other too.
          blocked.add(
            BusyBlock(slotStart, slotStart.add(Duration(minutes: sessionDuration))),
          );
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
    List<BusyBlock> blocked,
  ) {
    final end = start.add(Duration(minutes: duration));
    for (final block in blocked) {
      if (block.overlaps(start, end)) return true;
    }
    return false;
  }
}
