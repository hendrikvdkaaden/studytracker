import '../models/goal.dart';
import '../utils/calendar_helpers.dart';
import '../widgets/calendar/grid/calendar_day_cell.dart';
import 'goal_repository.dart';
import 'study_session_repository.dart';

/// Service responsible for determining goal statuses for calendar dates
class GoalStatusService {
  final GoalRepository _goalRepo;
  final StudySessionRepository _sessionRepo;

  GoalStatusService(this._goalRepo, this._sessionRepo);

  /// Gets the status indicators for all goals and sessions on a specific date
  List<GoalStatus> getStatusesForDate(DateTime date) {
    final statuses = _goalRepo
        .getAllGoals()
        .where((goal) => CalendarHelpers.isSameDay(goal.date, date))
        .map(_determineGoalStatus)
        .toList();

    final hasSessions = _sessionRepo.getPlannedSessionsByDate(date).isNotEmpty;
    if (hasSessions) statuses.add(GoalStatus.session);

    return statuses;
  }

  /// Determines the status of a single goal
  GoalStatus _determineGoalStatus(Goal goal) {
    if (goal.isCompleted) return GoalStatus.completed;
    if (goal.isOverdue()) return GoalStatus.overdue;
    return GoalStatus.upcoming;
  }
}
