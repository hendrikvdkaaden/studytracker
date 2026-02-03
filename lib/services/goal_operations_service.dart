import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/study_session.dart';
import 'goal_repository.dart';
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
    return updatedGoal;
  }

  /// Deletes a goal and all associated study sessions
  Future<void> deleteGoal(String goalId) async {
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

  /// Gets the total study time spent on a goal
  int getTotalStudyTime(String goalId) {
    return _sessionRepo.getTotalStudyTimeForGoal(goalId);
  }
}
