import 'package:flutter/material.dart';
import '../services/goal_repository.dart';
import '../models/goal.dart';
import '../widgets/home/goal_card.dart';
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
    final upcomingGoals = _goalRepo.getUpcomingGoals(30);
    final overdueGoals = _goalRepo.getOverdueGoals();
    final completedGoals = _goalRepo.getCompletedGoals();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (overdueGoals.isNotEmpty) ...[
          const Text(
            'Overdue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          ...overdueGoals.map((goal) => GoalCard(
                goal: goal,
                isOverdue: true,
                onTap: () => _navigateToDetails(goal),
              )),
          const SizedBox(height: 16),
        ],
        const Text(
          'Upcoming Deadlines',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (upcomingGoals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No upcoming deadlines.\nTap + to add a goal!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ...upcomingGoals.map((goal) => GoalCard(
                goal: goal,
                onTap: () => _navigateToDetails(goal),
              )),
        if (completedGoals.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Completed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          ...completedGoals.map((goal) => GoalCard(
                goal: goal,
                isCompleted: true,
                onTap: () => _navigateToDetails(goal),
              )),
        ],
      ],
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
