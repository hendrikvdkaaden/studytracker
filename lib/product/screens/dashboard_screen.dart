import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/day_status.dart';
import '../../models/study_session.dart';
import '../../services/goal_repository.dart';
import '../../services/study_session_repository.dart';
import '../../utils/calendar_helpers.dart';
import '../templates/dashboard_template.dart';
import 'add_goal_screen.dart';
import 'goal_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GoalRepository _goalRepo = GoalRepository();
  final StudySessionRepository _sessionRepo = StudySessionRepository();

  /// Returns the midnight at the end of the day a session was planned on.
  DateTime _endOfDay(StudySession s) =>
      DateTime(s.date.year, s.date.month, s.date.day + 1);

  /// A session is completed on time when completedAt is on the same day or earlier
  /// than the planned date. Falls back to isCompleted for sessions without completedAt.
  bool _isCompletedOnTime(StudySession s) {
    if (s.completedAt != null) {
      return !s.completedAt!.isAfter(_endOfDay(s));
    }
    // Legacy sessions without completedAt: trust isCompleted flag.
    return s.isCompleted;
  }

  /// A session is missed when the planned day is over and it was not completed on time.
  bool _isMissed(StudySession s, DateTime now) {
    if (_isCompletedOnTime(s)) return false;
    return _endOfDay(s).isBefore(now) || _endOfDay(s).isAtSameMomentAs(now);
  }

  Map<int, DayStatus> _getWeeklyConsistency() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = CalendarHelpers.getStartOfWeek(now);

    Map<int, DayStatus> weekData = {};

    for (int i = 0; i < 7; i++) {
      final date = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      );
      final weekday = i + 1; // 1=Monday, 7=Sunday

      final allSessions = _sessionRepo.getSessionsByDateRange(
        date,
        date.add(const Duration(days: 1)),
      );

      final isPastDay = date.isBefore(today);
      final allCompletedOnTime = allSessions.isNotEmpty &&
          allSessions.every(_isCompletedOnTime);
      final hasMissed = allSessions.any((s) => _isMissed(s, now));

      if (allCompletedOnTime) {
        weekData[weekday] = DayStatus.completed;
      } else if (hasMissed) {
        weekData[weekday] = DayStatus.missed;
      } else if (isPastDay) {
        weekData[weekday] = DayStatus.pastNoSession;
      } else {
        weekData[weekday] = DayStatus.notPlanned;
      }
    }

    return weekData;
  }

  int _getMissedSessionsCount() {
    final now = DateTime.now();
    final startOfWeek = CalendarHelpers.getStartOfWeek(now);

    int missedCount = 0;

    for (int i = 0; i < 7; i++) {
      final date = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      );

      final allSessions = _sessionRepo.getSessionsByDateRange(
        date,
        date.add(const Duration(days: 1)),
      );

      missedCount += allSessions.where((s) => _isMissed(s, now)).length;
    }

    return missedCount;
  }

  /// Returns the current streak: the number of consecutive days (going back from
  /// today) on which at least one session was completed on time.
  /// Days with no planned sessions are skipped — they don't break the streak.
  /// The streak only counts days that had at least one planned session.
  int _getStudyStreak() {
    final now = DateTime.now();
    int streak = 0;

    // Check up to 365 days back
    for (int i = 0; i < 365; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      final dayEnd = DateTime(day.year, day.month, day.day + 1);

      final sessions = _sessionRepo.getSessionsByDateRange(day, dayEnd);

      // Skip days with no planned sessions — don't break the streak
      if (sessions.isEmpty) continue;

      final hasCompletedOnTime = sessions.any(
        (s) => s.completedAt != null
            ? !s.completedAt!.isAfter(DateTime(s.date.year, s.date.month, s.date.day + 1))
            : s.isCompleted,
      );

      if (hasCompletedOnTime) {
        streak++;
      } else {
        // A planned session that was missed — streak is broken
        break;
      }
    }

    return streak;
  }

  Map<String, int> _getGoalsTimeSpent() {
    final Map<String, int> timeSpent = {};
    for (var goal in _goalRepo.getAllGoals()) {
      timeSpent[goal.id] = _sessionRepo.getTotalStudyTimeForGoal(goal.id);
    }
    return timeSpent;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddGoal,
        backgroundColor: const Color(0xFF6750A4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: DashboardTemplate(
        weeklyConsistency: _getWeeklyConsistency(),
        missedSessionsCount: _getMissedSessionsCount(),
        studyStreak: _getStudyStreak(),
        overdueGoals: _goalRepo.getOverdueGoals(),
        upcomingGoals: _goalRepo.getUpcomingGoals(30),
        completedGoals: _goalRepo.getCompletedGoals(),
        goalsTimeSpent: _getGoalsTimeSpent(),
        onGoalTap: _navigateToDetails,
      ),
    );
  }

  void _navigateToDetails(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailsScreen(goal: goal),
      ),
    ).then((_) => setState(() {}));
  }

  void _navigateToAddGoal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddGoalScreen(),
      ),
    ).then((_) => setState(() {}));
  }
}
