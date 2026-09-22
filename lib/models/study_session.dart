import 'package:hive/hive.dart';

part 'study_session.g.dart';

/// A study session that tracks time spent studying for a goal.
/// Can be either planned (isCompleted = false) or completed (isCompleted = true).
@HiveType(typeId: 3)
class StudySession extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String goalId;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  int duration;
  @HiveField(4)
  bool isCompleted;
  @HiveField(5)
  DateTime? startTime;
  @HiveField(6)
  String? notes;
  @HiveField(7)
  int? actualDuration;
  @HiveField(8)
  int? elapsedSeconds;
  @HiveField(9)
  DateTime? completedAt;

  /// Identifier of the matching event in the user's calendar, when calendar
  /// sync is on. Null when the session was never synced.
  @HiveField(10)
  String? calendarEventId;

  StudySession({
    required this.id,
    required this.goalId,
    required this.date,
    required this.duration,
    this.isCompleted = true,
    this.startTime,
    this.notes,
    this.actualDuration,
    this.elapsedSeconds,
    this.completedAt,
    this.calendarEventId,
  });

  /// Returns the duration as a formatted string (e.g., "1h 30m")
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Minutes actually studied, as the rest of the app reads them.
  ///
  /// Falls back to the planned duration for legacy sessions that were marked
  /// complete before actualDuration existed, so an old record does not read as
  /// zero minutes studied.
  int get studiedMinutes {
    final logged = actualDuration;
    if (logged != null) return logged;
    return isCompleted ? duration : 0;
  }

  /// Whether enough of this session was studied to count as done.
  ///
  /// The share rather than the whole: a user who studies 55 of 60 planned
  /// minutes has done the session, and demanding the last five would cost them
  /// the day. [home_screen] uses the strict `>= duration` rule to tick a
  /// session off its list; this is the softer rule the streak reads, so an
  /// early stop near the end does not silently break a streak overnight.
  static const double completionThreshold = 0.9;

  bool get isEffectivelyStudied {
    if (duration <= 0) return isCompleted;
    return studiedMinutes >= duration * completionThreshold;
  }

  /// The session as it should be saved when the user stops the timer after
  /// [elapsedSeconds].
  ///
  /// Stopping early is not finishing. Pressing Stop five minutes into a sixty
  /// minute session keeps the elapsed time and leaves the session open; only a
  /// timer that reached its target is marked complete.
  ///
  /// [actualDuration] accumulates rather than overwrites: a session stopped at
  /// 40 minutes, reopened and stopped again at 45 has studied 45 minutes, not
  /// 5. The timer resumes its clock from [resumeFrom], so [elapsedSeconds]
  /// already includes the earlier stretch -- but a session whose elapsed clock
  /// was reset (a finished one restarted) would otherwise throw the earlier
  /// total away, so the larger of the two wins.
  ///
  /// Built field by field rather than through [copyWith], because that helper
  /// reads `completedAt ?? this.completedAt` and so cannot clear a completion
  /// that no longer holds.
  StudySession stoppedAfter(int elapsedSeconds) {
    final reachedTarget = elapsedSeconds >= duration * 60;
    final loggedNow = elapsedSeconds ~/ 60;
    final previous = actualDuration ?? 0;

    return StudySession(
      id: id,
      goalId: goalId,
      date: date,
      duration: duration,
      startTime: startTime,
      notes: notes,
      calendarEventId: calendarEventId,
      actualDuration: loggedNow > previous ? loggedNow : previous,
      // A finished session reopening at 00:00 offers nothing but Restart, so
      // it resets; an interrupted one has to resume where it left off.
      elapsedSeconds: reachedTarget ? 0 : elapsedSeconds,
      isCompleted: reachedTarget,
      completedAt: reachedTarget ? DateTime.now() : null,
    );
  }

  /// The session as it should be saved when the user marks it complete by
  /// hand, having studied [elapsedSeconds].
  ///
  /// The same rule as [stoppedAfter] for what was studied -- overtime is kept,
  /// and an earlier stretch is never clamped away -- but the session is marked
  /// complete regardless of whether the clock reached its target, because the
  /// user said so. At minimum the planned duration is credited: marking a
  /// session complete means it was done.
  StudySession markedComplete(int elapsedSeconds) {
    final loggedNow = elapsedSeconds ~/ 60;
    final previous = actualDuration ?? 0;
    final studied = [loggedNow, previous, duration]
        .reduce((a, b) => a > b ? a : b);

    return StudySession(
      id: id,
      goalId: goalId,
      date: date,
      duration: duration,
      startTime: startTime,
      notes: notes,
      calendarEventId: calendarEventId,
      actualDuration: studied,
      // Reset so reopening starts a clean timer rather than one already
      // sitting at 00:00.
      elapsedSeconds: 0,
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  /// Elapsed seconds to reopen this session on.
  ///
  /// A completed session starts fresh; an interrupted one resumes.
  int get resumeFrom {
    if (!isCompleted && elapsedSeconds != null) return elapsedSeconds!;
    return 0;
  }

  StudySession copyWith({
    String? id,
    String? goalId,
    DateTime? date,
    int? duration,
    bool? isCompleted,
    DateTime? startTime,
    String? notes,
    int? actualDuration,
    int? elapsedSeconds,
    DateTime? completedAt,
    String? calendarEventId,
  }) {
    return StudySession(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      startTime: startTime ?? this.startTime,
      notes: notes ?? this.notes,
      actualDuration: actualDuration ?? this.actualDuration,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      completedAt: completedAt ?? this.completedAt,
      calendarEventId: calendarEventId ?? this.calendarEventId,
    );
  }
}
