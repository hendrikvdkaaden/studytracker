import 'package:flutter/material.dart';
import '../services/goal_repository.dart';
import '../models/goal.dart';
import '../widgets/home/modern_goal_card.dart';
import '../widgets/home/section_header.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        // Overdue Section
        if (overdueGoals.isNotEmpty) ...[
          const SectionHeader(
            title: 'Overdue',
            color: Colors.red,
          ),
          ...overdueGoals.map((goal) => ModernGoalCard(
                goal: goal,
                isOverdue: true,
                onTap: () => _navigateToDetails(goal),
              )),
          const SizedBox(height: 16),
        ],

        // Upcoming Section
        const SectionHeader(
          title: 'Upcoming Deadlines',
          color: Color(0xFF135BEC),
        ),
        if (upcomingGoals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                'No upcoming deadlines.\nTap + to add a goal!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ...upcomingGoals.map((goal) => ModernGoalCard(
                goal: goal,
                onTap: () => _navigateToDetails(goal),
              )),

        // Completed Section
        if (completedGoals.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Completed',
            color: Colors.green,
          ),
          ...completedGoals.map((goal) => Opacity(
                opacity: 0.8,
                child: ModernGoalCard(
                  goal: goal,
                  isCompleted: true,
                  onTap: () => _navigateToDetails(goal),
                ),
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
