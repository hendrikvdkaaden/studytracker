import '../models/goal.dart';
import '../utils/calendar_helpers.dart';
import '../widgets/calendar/grid/calendar_day_cell.dart';
import 'goal_repository.dart';

/// Service responsible for determining goal statuses for calendar dates
class GoalStatusService {
  final GoalRepository _goalRepo;

  GoalStatusService(this._goalRepo);

  /// Gets the status indicators for all goals on a specific date
  List<GoalStatus> getStatusesForDate(DateTime date) {
    final goalsForDate = _getGoalsForDate(date);
    return goalsForDate.map(_determineGoalStatus).toList();
  }

  /// Retrieves all goals that have a deadline on the specified date
  List<Goal> _getGoalsForDate(DateTime date) {
    return _goalRepo
        .getAllGoals()
        .where((goal) => CalendarHelpers.isSameDay(goal.date, date))
        .toList();
  }

  /// Determines the status of a single goal
  GoalStatus _determineGoalStatus(Goal goal) {
    if (goal.isCompleted) return GoalStatus.completed;
    if (goal.isOverdue()) return GoalStatus.overdue;
    return GoalStatus.upcoming;
  }
}
