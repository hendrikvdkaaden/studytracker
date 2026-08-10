import '../models/study_session.dart';

/// Pure study-streak and session-status rules, kept out of the widget layer so
/// they can be tested directly.
class StreakService {
  /// Midnight at the end of the day a session was planned on.
  static DateTime endOfDay(StudySession s) =>
      DateTime(s.date.year, s.date.month, s.date.day + 1);

  /// A session is completed on time when completedAt falls on the planned day
  /// or earlier. Legacy sessions without completedAt fall back to isCompleted.
  static bool isCompletedOnTime(StudySession s) {
    if (s.completedAt != null) {
      return !s.completedAt!.isAfter(endOfDay(s));
    }
    return s.isCompleted;
  }

  /// A session is missed once its day is over and it was not completed on time.
  static bool isMissed(StudySession s, DateTime now) {
    if (isCompletedOnTime(s)) return false;
    final end = endOfDay(s);
    return end.isBefore(now) || end.isAtSameMomentAs(now);
  }

  /// Number of consecutive days, counting back from [now], on which every
  /// planned session was completed on time.
  ///
  /// Two rules shape the result:
  /// - Days with no planned sessions are skipped: they neither extend nor
  ///   break the streak.
  /// - Today is skipped while its sessions are still outstanding, so a streak
  ///   already earned stays visible during the day. Only an elapsed day with
  ///   unfinished sessions breaks it.
  static int calculateStreak({
    required List<StudySession> sessions,
    required DateTime now,
  }) {
    if (sessions.isEmpty) return 0;

    // The scan below only ever looks back 365 days, so ignore anything older.
    // This keeps the group-by from touching a user's entire session history on
    // every dashboard rebuild.
    final today = DateTime(now.year, now.month, now.day);
    final earliest = DateTime(today.year, today.month, today.day - 364);

    // Group by calendar day so the scan below is a cheap map lookup instead of
    // a repeated pass over every session.
    final byDay = <DateTime, List<StudySession>>{};
    for (final s in sessions) {
      final day = DateTime(s.date.year, s.date.month, s.date.day);
      if (day.isBefore(earliest) || day.isAfter(today)) continue;
      byDay.putIfAbsent(day, () => []).add(s);
    }

    var streak = 0;
    for (var i = 0; i < 365; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      final daySessions = byDay[day];

      // No sessions planned: does not count, does not break.
      if (daySessions == null || daySessions.isEmpty) continue;

      if (daySessions.every(isCompletedOnTime)) {
        streak++;
      } else if (i == 0) {
        // Today is still in progress: it cannot extend the streak yet, but it
        // must not break one the user already earned.
        continue;
      } else {
        break;
      }
    }

    return streak;
  }
}
