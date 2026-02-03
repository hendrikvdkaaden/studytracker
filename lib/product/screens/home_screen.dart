import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../services/goal_repository.dart';
import '../templates/home_template.dart';
import 'goal_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoalRepository _goalRepo = GoalRepository();

  @override
  Widget build(BuildContext context) {
    return HomeTemplate(
      overdueGoals: _goalRepo.getOverdueGoals(),
      upcomingGoals: _goalRepo.getUpcomingGoals(30),
      completedGoals: _goalRepo.getCompletedGoals(),
      onGoalTap: _navigateToDetails,
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
}
