import '../models/goal.dart';
import '../models/study_session.dart';

/// Turns goals and sessions into the shape a calendar event needs.
///
/// Kept separate from [CalendarSyncService] so the rules can be tested without
/// touching the platform channel.
class CalendarEventMapper {
  /// Hour used when a session has no explicit start time. Mirrors the fallback
  /// in NotificationService so a session's reminder and its calendar entry
  /// never disagree.
  static const int defaultStartHour = 9;

  /// When a session starts. Falls back to [defaultStartHour] on its planned
  /// day if the user never picked a time.
  static DateTime sessionStart(StudySession session) {
    final start = session.startTime;
    if (start != null) return start;
    return DateTime(
      session.date.year,
      session.date.month,
      session.date.day,
      defaultStartHour,
    );
  }

  /// When a session ends: its start plus the planned duration.
  static DateTime sessionEnd(StudySession session) =>
      sessionStart(session).add(Duration(minutes: session.duration));

  /// Title shown in the calendar, e.g. "Study: Chapter 5 Exam".
  static String sessionTitle(String goalTitle) => 'Study: $goalTitle';

  /// Body of a session entry: the subject, plus the user's own note when they
  /// wrote one. Returns null when there is nothing worth showing, so the
  /// calendar does not render an empty notes field.
  static String? sessionDescription(String subject, String? notes) {
    final parts = <String>[];
    final trimmedSubject = subject.trim();
    if (trimmedSubject.isNotEmpty) parts.add(trimmedSubject);

    final trimmedNotes = notes?.trim();
    if (trimmedNotes != null && trimmedNotes.isNotEmpty) {
      parts.add(trimmedNotes);
    }

    if (parts.isEmpty) return null;
    return parts.join('\n\n');
  }

  /// Title for a deadline, e.g. "Deadline (Math): Chapter 5 Exam".
  ///
  /// The subject is named up front so a deadline is recognisable in a week
  /// view, where the calendar often cuts the title off after a few words.
  /// A goal without a subject falls back to a plain "Deadline: ...".
  static String deadlineTitle(Goal goal) {
    final subject = goal.subject.trim();
    if (subject.isEmpty) return 'Deadline: ${goal.title}';
    return 'Deadline ($subject): ${goal.title}';
  }

  /// Deadlines are all-day entries, so the span is the whole calendar day.
  static DateTime deadlineStart(Goal goal) =>
      DateTime(goal.date.year, goal.date.month, goal.date.day);

  static DateTime deadlineEnd(Goal goal) =>
      deadlineStart(goal).add(const Duration(days: 1));

  /// Whether a goal should get a calendar entry when sync is switched on.
  ///
  /// Only future, unfinished deadlines: backfilling history would dump the
  /// user's entire past into their calendar.
  static bool shouldSyncGoal(Goal goal, DateTime now) {
    if (goal.isCompleted) return false;
    return !goal.date.isBefore(_startOfDay(now));
  }

  /// Whether a session should get a calendar entry when sync is switched on.
  static bool shouldSyncSession(StudySession session, DateTime now) {
    if (session.isCompleted) return false;
    return !session.date.isBefore(_startOfDay(now));
  }

  /// Compares on whole days, so something due later today still counts as
  /// upcoming rather than past.
  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
}
