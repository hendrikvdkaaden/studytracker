import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/day_status.dart';
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

      // Get all sessions for this date
      final allSessions = _sessionRepo.getSessionsByDateRange(
        date,
        date.add(const Duration(days: 1)),
      );

      final hasCompleted = allSessions.any((s) => s.isCompleted);
      final hasPlanned = allSessions.any((s) => !s.isCompleted);
      final isPast = date.isBefore(today);

      if (hasCompleted) {
        weekData[weekday] = DayStatus.completed;
      } else if (hasPlanned && isPast) {
        weekData[weekday] = DayStatus.missed;
      } else if (isPast) {
        weekData[weekday] = DayStatus.pastNoSession;
      } else {
        weekData[weekday] = DayStatus.notPlanned;
      }
    }

    return weekData;
  }

  int _getMissedSessionsCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = CalendarHelpers.getStartOfWeek(now);

    int missedCount = 0;

    for (int i = 0; i < 7; i++) {
      final date = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + i,
      );

      final isPast = date.isBefore(today);
      if (!isPast) continue;

      final allSessions = _sessionRepo.getSessionsByDateRange(
        date,
        date.add(const Duration(days: 1)),
      );

      final hasCompleted = allSessions.any((s) => s.isCompleted);
      final plannedSessions = allSessions.where((s) => !s.isCompleted).toList();

      if (!hasCompleted && plannedSessions.isNotEmpty) {
        missedCount += plannedSessions.length;
      }
    }

    return missedCount;
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
