import 'package:flutter/material.dart';
import '../services/goal_repository.dart';
import '../models/goal.dart';

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
          ...overdueGoals.map((goal) => _buildGoalCard(goal, isOverdue: true)),
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
          ...upcomingGoals.map((goal) => _buildGoalCard(goal)),
      ],
    );
  }

  Widget _buildGoalCard(Goal goal, {bool isOverdue = false}) {
    final daysLeft = goal.daysUntilDeadline();
    final color = isOverdue
        ? Colors.red
        : daysLeft <= 3
            ? Colors.orange
            : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(
            _getIconForType(goal.type),
            color: color,
          ),
        ),
        title: Text(
          goal.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.subject),
            const SizedBox(height: 4),
            Text(
              isOverdue
                  ? '${daysLeft.abs()} days overdue'
                  : '$daysLeft days left',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            _getDifficultyLabel(goal.difficulty),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getDifficultyColor(goal.difficulty),
        ),
        onTap: () {
          // TODO: Navigate to goal details
        },
      ),
    );
  }

  IconData _getIconForType(GoalType type) {
    switch (type) {
      case GoalType.exam:
        return Icons.school;
      case GoalType.test:
        return Icons.quiz;
      case GoalType.assignment:
        return Icons.assignment;
      case GoalType.presentation:
        return Icons.present_to_all;
      case GoalType.project:
        return Icons.work;
      case GoalType.paper:
        return Icons.description;
      case GoalType.quiz:
        return Icons.question_answer;
      case GoalType.other:
        return Icons.more_horiz;
    }
  }

  String _getDifficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.veryHard:
        return 'Very Hard';
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green.shade100;
      case Difficulty.medium:
        return Colors.yellow.shade100;
      case Difficulty.hard:
        return Colors.orange.shade100;
      case Difficulty.veryHard:
        return Colors.red.shade100;
    }
  }
}
