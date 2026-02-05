import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../widgets/deadlines/cards/modern_goal_card.dart';
import '../../widgets/deadlines/headers/section_header.dart';

/// Layout template for the deadlines screen displaying categorized goals
class HomeTemplate extends StatelessWidget {
  final List<Goal> overdueGoals;
  final List<Goal> upcomingGoals;
  final List<Goal> completedGoals;
  final Function(Goal) onGoalTap;

  const HomeTemplate({
    super.key,
    required this.overdueGoals,
    required this.upcomingGoals,
    required this.completedGoals,
    required this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        if (overdueGoals.isNotEmpty) ...[
          _buildOverdueSection(),
          const SizedBox(height: 16),
        ],
        _buildUpcomingSection(),
        if (completedGoals.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildCompletedSection(),
        ],
      ],
    );
  }

  Widget _buildOverdueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Overdue',
          color: Colors.red,
        ),
        ...overdueGoals.map((goal) => ModernGoalCard(
              goal: goal,
              isOverdue: true,
              onTap: () => onGoalTap(goal),
            )),
      ],
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Upcoming Deadlines',
          color: Color(0xFF135BEC),
        ),
        if (upcomingGoals.isEmpty)
          _buildEmptyState()
        else
          ...upcomingGoals.map((goal) => ModernGoalCard(
                goal: goal,
                onTap: () => onGoalTap(goal),
              )),
      ],
    );
  }

  Widget _buildCompletedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Completed',
          color: Colors.green,
        ),
        ...completedGoals.map((goal) => Opacity(
              opacity: 0.8,
              child: ModernGoalCard(
                goal: goal,
                isCompleted: true,
                onTap: () => onGoalTap(goal),
              ),
            )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }
}
