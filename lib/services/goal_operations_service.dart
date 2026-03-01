import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/study_session.dart';
import 'goal_repository.dart';
import 'notification_service.dart';
import 'study_session_repository.dart';

/// Service for handling goal operations (update, delete, progress adjustments)
class GoalOperationsService {
  final GoalRepository _goalRepo;
  final StudySessionRepository _sessionRepo;

  GoalOperationsService({
    GoalRepository? goalRepo,
    StudySessionRepository? sessionRepo,
  })  : _goalRepo = goalRepo ?? GoalRepository(),
        _sessionRepo = sessionRepo ?? StudySessionRepository();

  /// Toggles the completion status of a goal
  Future<Goal> toggleComplete(Goal goal) async {
    final updatedGoal = goal.copyWith(isCompleted: !goal.isCompleted);
    await _goalRepo.updateGoal(updatedGoal);

    if (updatedGoal.isCompleted) {
      // Cancel notifications when marking as completed
      final sessions = _sessionRepo.getPlannedSessionsByGoalId(goal.id);
      await NotificationService.cancelGoalNotifications(goal.id, sessions);
    } else {
      // Re-schedule notifications when un-completing
      await NotificationService.scheduleDeadlineReminder(updatedGoal);
      final sessions = _sessionRepo.getPlannedSessionsByGoalId(goal.id);
      for (final session in sessions) {
        await NotificationService.scheduleSessionReminder(
            session, updatedGoal.title);
      }
    }

    return updatedGoal;
  }

  /// Deletes a goal and all associated study sessions
  Future<void> deleteGoal(String goalId) async {
    // Cancel notifications first
    final sessions = _sessionRepo.getPlannedSessionsByGoalId(goalId);
    await NotificationService.cancelGoalNotifications(goalId, sessions);

    // Delete all associated study sessions
    await _sessionRepo.deleteSessionsByGoalId(goalId);

    // Then delete the goal itself
    await _goalRepo.deleteGoal(goalId);
  }

  /// Updates the goal's target time and adjusts time spent
  Future<Goal> updateProgress({
    required Goal goal,
    required int newTargetTimeMinutes,
    required int newTimeSpentMinutes,
  }) async {
    // Update goal's target time
    final updatedGoal = goal.copyWith(studyTime: newTargetTimeMinutes);
    await _goalRepo.updateGoal(updatedGoal);

    // Calculate difference in time spent and adjust sessions
    final currentTimeSpent = _sessionRepo.getTotalStudyTimeForGoal(goal.id);
    final difference = newTimeSpentMinutes - currentTimeSpent;

    if (difference != 0) {
      // Create adjustment session
      final adjustmentSession = StudySession(
        id: const Uuid().v4(),
        goalId: goal.id,
        date: DateTime.now(),
        duration: difference,
      );
      await _sessionRepo.addSession(adjustmentSession);
    }

    return updatedGoal;
  }

  /// Updates a goal's basic data (title, subject, type, difficulty, date, etc.)
  /// Also reschedules the deadline reminder notification if the goal is not completed.
  Future<void> updateGoalData(Goal goal) async {
    await _goalRepo.updateGoal(goal);
    if (!goal.isCompleted) {
      await NotificationService.scheduleDeadlineReminder(goal);
    }
  }

  /// Gets the total study time spent on a goal
  int getTotalStudyTime(String goalId) {
    return _sessionRepo.getTotalStudyTimeForGoal(goalId);
  }
}
