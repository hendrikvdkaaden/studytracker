import 'package:hive/hive.dart';
import '../models/goal.dart';
import '../models/study_session.dart';
import 'hive_service.dart';

/// Repository for managing Goal CRUD operations
class GoalRepository {
  final Box<Goal> _box = HiveService.getGoalsBox();

  /// Get all goals
  List<Goal> getAllGoals() {
    return _box.values.toList();
  }

  /// Get a goal by ID
  Goal? getGoalById(String id) {
    try {
      return _box.values.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all goals for a specific subject
  List<Goal> getGoalsBySubject(String subject) {
    return _box.values.where((goal) => goal.subject == subject).toList();
  }

  /// Get all incomplete goals
  List<Goal> getIncompleteGoals() {
    return _box.values.where((goal) => !goal.isCompleted).toList();
  }

  /// Get all completed goals
  List<Goal> getCompletedGoals() {
    return _box.values.where((goal) => goal.isCompleted).toList();
  }

  /// Get all overdue goals
  List<Goal> getOverdueGoals() {
    return _box.values.where((goal) => goal.isOverdue()).toList();
  }

  /// Get upcoming goals (within next N days)
  List<Goal> getUpcomingGoals(int days) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return _box.values
        .where((goal) =>
            !goal.isCompleted &&
            goal.date.isAfter(now) &&
            goal.date.isBefore(futureDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Add a new goal
  Future<void> addGoal(Goal goal) async {
    await _box.put(goal.id, goal);
  }

  /// Update an existing goal
  Future<void> updateGoal(Goal goal) async {
    await _box.put(goal.id, goal);
  }

  /// Delete a goal
  /// Note: Use GoalOperationsService.deleteGoal() to also delete associated sessions
  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
  }

  /// Toggle goal completion status
  Future<void> toggleGoalCompletion(String id) async {
    final goal = getGoalById(id);
    if (goal != null) {
      final updatedGoal = goal.copyWith(isCompleted: !goal.isCompleted);
      await updateGoal(updatedGoal);
    }
  }

  /// Clear all goals
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Get total number of goals
  int getTotalCount() {
    return _box.length;
  }

  /// Update goal's studyTime based on all its sessions
  /// Pass sessions from outside to avoid circular dependency
  Future<void> updateGoalStudyTime(String goalId, List<StudySession> sessions) async {
    final goal = getGoalById(goalId);
    if (goal != null) {
      final totalDuration = sessions.fold<int>(0, (sum, session) => sum + session.duration);

      if (goal.studyTime != totalDuration) {
        final updatedGoal = goal.copyWith(studyTime: totalDuration);
        await updateGoal(updatedGoal);
      }
    }
  }
}
