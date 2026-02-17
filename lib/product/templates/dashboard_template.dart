import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../widgets/deadlines/cards/overdue_goal_card.dart';
import '../../widgets/deadlines/cards/upcoming_goal_card.dart';
import '../../widgets/deadlines/cards/completed_goal_card.dart';
import '../../models/day_status.dart';
import '../../widgets/deadlines/cards/study_consistency_card.dart';

class DashboardTemplate extends StatelessWidget {
  final Map<int, DayStatus> weeklyConsistency;
  final int missedSessionsCount;
  final List<Goal> overdueGoals;
  final List<Goal> upcomingGoals;
  final List<Goal> completedGoals;
  final Map<String, int> goalsTimeSpent;
  final Function(Goal) onGoalTap;

  const DashboardTemplate({
    super.key,
    required this.weeklyConsistency,
    required this.missedSessionsCount,
    required this.overdueGoals,
    required this.upcomingGoals,
    required this.completedGoals,
    required this.goalsTimeSpent,
    required this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // Study Consistency
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: StudyConsistencyCard(
            weeklyConsistency: weeklyConsistency,
            missedSessionsCount: missedSessionsCount,
          ),
        ),
        // Overdue section
        if (overdueGoals.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: isDark
                          ? const Color(0xFFf2b8b5)
                          : const Color(0xFFb3261e),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Overdue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFf2b8b5)
                            : const Color(0xFFb3261e),
                      ),
                    ),
                  ],
                ),
                if (overdueGoals.length > 2)
                  Text(
                    'SEE ALL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      letterSpacing: 1.5,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: overdueGoals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final goal = overdueGoals[index];
                return OverdueGoalCard(
                  goal: goal,
                  onTap: () => onGoalTap(goal),
                );
              },
            ),
          ),
        ],

        // Upcoming section
        if (upcomingGoals.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF6750A4),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Upcoming',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1d1b20),
                      ),
                    ),
                  ],
                ),
                if (upcomingGoals.length > 3)
                  Text(
                    'SEE ALL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      letterSpacing: 1.5,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: upcomingGoals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final goal = upcomingGoals[index];
                return UpcomingGoalCard(
                  goal: goal,
                  timeSpent: goalsTimeSpent[goal.id] ?? 0,
                  onTap: () => onGoalTap(goal),
                );
              },
            ),
          ),
        ],

        // Completed section
        if (completedGoals.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: isDark ? Colors.green.shade400 : Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.green.shade400
                        : Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 150,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: completedGoals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final goal = completedGoals[index];
                return CompletedGoalCard(
                  goal: goal,
                  timeSpent: goalsTimeSpent[goal.id] ?? 0,
                  onTap: () => onGoalTap(goal),
                );
              },
            ),
          ),
        ],

        // Empty state
        if (overdueGoals.isEmpty &&
            upcomingGoals.isEmpty &&
            completedGoals.isEmpty)
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No goals yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create your first goal',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[700] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
