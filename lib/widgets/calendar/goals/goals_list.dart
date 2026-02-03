import 'package:flutter/material.dart';
import '../../../models/goal.dart';
import '../../../product/screens/goal_details_screen.dart';
import 'deadline_list_item.dart';

class GoalsList extends StatelessWidget {
  final List<Goal> goals;
  final VoidCallback onGoalUpdated;

  const GoalsList({
    super.key,
    required this.goals,
    required this.onGoalUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: goals.length,
      itemBuilder: (context, index) => _buildGoalItem(context, goals[index]),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No deadlines for this day',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, Goal goal) {
    return DeadlineListItem(
      goal: goal,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoalDetailsScreen(goal: goal),
          ),
        );
        onGoalUpdated();
      },
    );
  }
}
