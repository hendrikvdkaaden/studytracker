import '../models/goal.dart';
import 'goal_repository.dart';
import 'calendar_sync_service.dart';
import 'notification_service.dart';
import 'study_session_repository.dart';

/// Service for handling goal operations (update, delete, completion)
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
      // The deadline is discharged, so drop its calendar entry too.
      await CalendarSyncService.deleteEvent(updatedGoal.calendarEventId);
      updatedGoal.calendarEventId = null;
      await _goalRepo.updateGoal(updatedGoal);
    } else {
      // Re-schedule notifications when un-completing
      await NotificationService.scheduleDeadlineReminder(updatedGoal);
      await _syncDeadline(updatedGoal);
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

    // Remove calendar entries while the records still hold their event ids.
    await CalendarSyncService.deleteEvents(
      sessions.map((s) => s.calendarEventId),
    );
    await CalendarSyncService.deleteEvent(
      _goalRepo.getGoalById(goalId)?.calendarEventId,
    );

    // Delete all associated study sessions
    await _sessionRepo.deleteSessionsByGoalId(goalId);

    // Then delete the goal itself
    await _goalRepo.deleteGoal(goalId);
  }

  /// Updates a goal's basic data (title, subject, type, date, etc.)
  /// Also reschedules the deadline reminder notification if the goal is not completed.
  Future<void> updateGoalData(Goal goal) async {
    await _goalRepo.updateGoal(goal);
    if (!goal.isCompleted) {
      await NotificationService.scheduleDeadlineReminder(goal);
      await _syncDeadline(goal);
    }
  }

  /// Replaces the goal's calendar entry so a changed title or date takes
  /// effect, then stores the new event id.
  ///
  /// Delete-then-create rather than update: it is one code path, and it
  /// handles an event the user already removed from their calendar.
  Future<void> _syncDeadline(Goal goal) async {
    if (!CalendarSyncService.isEnabled) return;
    await CalendarSyncService.deleteEvent(goal.calendarEventId);
    final eventId = await CalendarSyncService.syncDeadline(goal);
    if (eventId == null) return;
    goal.calendarEventId = eventId;
    await _goalRepo.updateGoal(goal);
  }

  /// Gets the total study time spent on a goal
  int getTotalStudyTime(String goalId) {
    return _sessionRepo.getTotalStudyTimeForGoal(goalId);
  }
}
