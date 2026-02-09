import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../services/goal_repository.dart';
import '../../services/study_session_repository.dart';
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

  int _getCompletedHoursThisWeek() {
    final totalMinutes = _sessionRepo.getTotalStudyTimeThisWeek();
    return totalMinutes ~/ 60;
  }

  int _getTargetHoursThisWeek() {
    // Calculate target as sum of all incomplete goals this week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final goals = _goalRepo.getAllGoals().where((goal) {
      if (goal.isCompleted) return false;
      return goal.date.isAfter(startOfWeek) && goal.date.isBefore(endOfWeek);
    });

    final totalMinutes = goals.fold(0, (sum, goal) => sum + goal.studyTime);
    return totalMinutes ~/ 60;
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
        completedHoursThisWeek: _getCompletedHoursThisWeek(),
        targetHoursThisWeek: _getTargetHoursThisWeek(),
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
