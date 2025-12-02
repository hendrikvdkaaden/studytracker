import 'package:hive/hive.dart';
import '../models/study_session.dart';
import 'hive_service.dart';

/// Repository for managing StudySession CRUD operations
class StudySessionRepository {
  final Box<StudySession> _box = HiveService.getStudySessionsBox();

  /// Get all study sessions
  List<StudySession> getAllSessions() {
    return _box.values.toList();
  }

  /// Get a study session by ID
  StudySession? getSessionById(String id) {
    return _box.values.firstWhere(
      (session) => session.id == id,
      orElse: () => throw Exception('Study session not found'),
    );
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

  /// Get total study time for a specific goal (in minutes)
  int getTotalStudyTimeForGoal(String goalId) {
    return getSessionsByGoalId(goalId)
        .fold(0, (total, session) => total + session.duration);
  }

  /// Get total study time for today (in minutes)
  int getTotalStudyTimeToday() {
    return getTodaySessions()
        .fold(0, (total, session) => total + session.duration);
  }

  /// Get total study time for this week (in minutes)
  int getTotalStudyTimeThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekDay.add(const Duration(days: 7));

    return getSessionsByDateRange(startOfWeekDay, endOfWeek)
        .fold(0, (total, session) => total + session.duration);
  }

  /// Add a new study session
  Future<void> addSession(StudySession session) async {
    await _box.put(session.id, session);
  }

  /// Update an existing study session
  Future<void> updateSession(StudySession session) async {
    await _box.put(session.id, session);
  }

  /// Delete a study session
  Future<void> deleteSession(String id) async {
    await _box.delete(id);
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
