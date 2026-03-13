import 'package:uuid/uuid.dart';
import '../models/study_session.dart';

class AutoPlannerService {
  static List<StudySession> generateSessions({
    required String goalId,
    required DateTime deadline,
    required int totalMinutes,
    required List<int> weekdays, // 1=Ma .. 7=Zo
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required int sessionDuration, // minutes
    required List<StudySession> existingSessions,
  }) {
    final sessions = <StudySession>[];
    if (sessionDuration <= 0 || weekdays.isEmpty) return sessions;

    final sessionCount = (totalMinutes / sessionDuration).ceil();
    if (sessionCount <= 0) return sessions;

    // Start from tomorrow
    DateTime current = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).add(const Duration(days: 1));

    final deadlineDay = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    );

    int added = 0;

    while (!current.isAfter(deadlineDay) && added < sessionCount) {
      if (weekdays.contains(current.weekday)) {
        final startTime = DateTime(
          current.year,
          current.month,
          current.day,
          startHour,
          startMinute,
        );
        if (!_hasOverlap(startTime, sessionDuration, existingSessions)) {
          sessions.add(StudySession(
            id: const Uuid().v4(),
            goalId: goalId,
            date: current,
            duration: sessionDuration,
            isCompleted: false,
            startTime: startTime,
          ));
          added++;
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return sessions;
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
