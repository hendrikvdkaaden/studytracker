import '../models/goal.dart';
import '../models/study_session.dart';
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
      // The goal is discharged, so drop its calendar entries too: the
      // deadline and every study block still planned for it.
      await CalendarSyncService.deleteEvent(updatedGoal.calendarEventId);
      updatedGoal.calendarEventId = null;
      await _goalRepo.updateGoal(updatedGoal);
      await _clearSessionEvents(sessions);
    } else {
      // Re-schedule notifications when un-completing
      await NotificationService.scheduleDeadlineReminder(updatedGoal);
      await _syncDeadline(updatedGoal);
      final sessions = _sessionRepo.getPlannedSessionsByGoalId(goal.id);
      for (final session in sessions) {
        await NotificationService.scheduleSessionReminder(
            session, updatedGoal.title);
        // Restore the study block dropped when the goal was completed, so
        // completing and un-completing round-trips.
        await _syncSession(session, updatedGoal);
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
    // Every session goes, not just the planned ones: a session already run
    // through the timer still holds the event id it got while it was planned.
    await CalendarSyncService.deleteEvents(
      _sessionRepo.getSessionsByGoalId(goalId).map((s) => s.calendarEventId),
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
  /// Create-then-delete rather than update: it is one code path, and it
  /// handles an event the user already removed from their calendar. The new
  /// entry is written *before* the old one is removed, so a failed write
  /// leaves the previous entry in place instead of losing the deadline from
  /// the calendar entirely.
  Future<void> _syncDeadline(Goal goal) async {
    if (!CalendarSyncService.isEnabled) return;
    final previousEventId = goal.calendarEventId;
    final eventId = await CalendarSyncService.syncDeadline(goal);
    if (eventId == null) return;
    goal.calendarEventId = eventId;
    await _goalRepo.updateGoal(goal);
    await CalendarSyncService.deleteEvent(previousEventId);
  }

  /// Writes a study block for [session] and stores its event id.
  Future<void> _syncSession(StudySession session, Goal goal) async {
    if (!CalendarSyncService.isEnabled) return;
    final eventId = await CalendarSyncService.syncSession(
      session,
      goal.title,
      goal.subject,
    );
    if (eventId == null) return;
    await _sessionRepo.updateSession(
      session.copyWith(calendarEventId: eventId),
    );
  }

  /// Removes the calendar entries for [sessions] and forgets their event ids,
  /// so nothing later points at an entry that no longer exists.
  Future<void> _clearSessionEvents(List<StudySession> sessions) async {
    for (final session in sessions) {
      if (session.calendarEventId == null) continue;
      await CalendarSyncService.deleteEvent(session.calendarEventId);
      // Assigned directly rather than via copyWith: copyWith falls back to the
      // current value on null, so it cannot clear a field.
      session.calendarEventId = null;
      await _sessionRepo.updateSession(session);
    }
  }

  /// Gets the total study time spent on a goal
  int getTotalStudyTime(String goalId) {
    return _sessionRepo.getTotalStudyTimeForGoal(goalId);
  }
}
