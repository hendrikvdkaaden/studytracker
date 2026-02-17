import 'package:hive/hive.dart';
import '../models/study_session.dart';
import '../utils/calendar_helpers.dart';
import 'hive_service.dart';
import 'goal_repository.dart';

/// Repository for managing StudySession CRUD operations
class StudySessionRepository {
  final Box<StudySession> _box = HiveService.getStudySessionsBox();

  Future<void> _updateGoalStudyTime(String goalId) async {
    final goalRepo = GoalRepository();
    final sessions = getSessionsByGoalId(goalId);
    await goalRepo.updateGoalStudyTime(goalId, sessions);
  }

  /// Get all study sessions
  List<StudySession> getAllSessions() {
    return _box.values.toList();
  }

  /// Get a study session by ID
  StudySession? getSessionById(String id) {
    try {
      return _box.values.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all study sessions for a specific goal
  List<StudySession> getSessionsByGoalId(String goalId) {
    return _box.values
        .where((session) => session.goalId == goalId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  /// Get study sessions within a date range
  List<StudySession> getSessionsByDateRange(DateTime start, DateTime end) {
    return _box.values
        .where((session) =>
            session.date.isAfter(start) && session.date.isBefore(end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get today's study sessions
  List<StudySession> getTodaySessions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getSessionsByDateRange(startOfDay, endOfDay);
  }

  /// Get total study time for a specific goal (in minutes) - uses actualDuration if available
  int getTotalStudyTimeForGoal(String goalId) {
    return getSessionsByGoalId(goalId).fold(0, (total, session) {
      // Use actualDuration if available, otherwise fall back to duration for completed sessions
      if (session.actualDuration != null && session.actualDuration! > 0) {
        return total + session.actualDuration!;
      } else if (session.isCompleted) {
        return total + session.duration;
      }
      return total;
    });
  }

  /// Get total study time for today (in minutes)
  int getTotalStudyTimeToday() {
    return getTodaySessions()
        .fold(0, (total, session) => total + session.duration);
  }

  /// Get total study time for this week (in minutes)
  int getTotalStudyTimeThisWeek() {
    final now = DateTime.now();
    final startOfWeek = CalendarHelpers.getStartOfWeek(now);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return getSessionsByDateRange(startOfWeek, endOfWeek)
        .fold(0, (total, session) => total + session.duration);
  }

  /// Get planned (not completed) sessions for a specific goal
  List<StudySession> getPlannedSessionsByGoalId(String goalId) {
    return _box.values
        .where((session) => session.goalId == goalId && !session.isCompleted)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // Earliest first
  }

  /// Get completed sessions for a specific goal
  List<StudySession> getCompletedSessionsByGoalId(String goalId) {
    return _box.values
        .where((session) => session.goalId == goalId && session.isCompleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  /// Get planned sessions for a specific date
  List<StudySession> getPlannedSessionsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _box.values
        .where((session) {
          // Check if session.date is on the same day
          final sessionDay = DateTime(
            session.date.year,
            session.date.month,
            session.date.day,
          );

          return sessionDay.year == date.year &&
                 sessionDay.month == date.month &&
                 sessionDay.day == date.day;
        })
        .toList()
      ..sort((a, b) {
        // Sort by start time if available, otherwise by date
        if (a.startTime != null && b.startTime != null) {
          return a.startTime!.compareTo(b.startTime!);
        }
        return a.date.compareTo(b.date);
      });
  }

  /// Get all planned sessions
  List<StudySession> getAllPlannedSessions() {
    return _box.values
        .where((session) => !session.isCompleted)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Add a new study session
  Future<void> addSession(StudySession session) async {
    await _box.put(session.id, session);
    await _updateGoalStudyTime(session.goalId);
  }

  /// Update an existing study session
  Future<void> updateSession(StudySession session) async {
    await _box.put(session.id, session);
    await _updateGoalStudyTime(session.goalId);
  }

  /// Delete a study session
  Future<void> deleteSession(String id) async {
    final session = getSessionById(id);
    await _box.delete(id);
    if (session != null) {
      await _updateGoalStudyTime(session.goalId);
    }
  }

  /// Delete all sessions for a specific goal
  Future<void> deleteSessionsByGoalId(String goalId) async {
    final sessions = getSessionsByGoalId(goalId);
    for (var session in sessions) {
      await _box.delete(session.id);
    }
  }

  /// Clear all study sessions
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Get total number of study sessions
  int getTotalCount() {
    return _box.length;
  }
}
