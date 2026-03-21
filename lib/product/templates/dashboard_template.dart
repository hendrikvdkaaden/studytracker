import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../theme/app_colors.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/deadlines/cards/overdue_goal_card.dart';
import '../../widgets/deadlines/cards/upcoming_goal_card.dart';
import '../../widgets/deadlines/cards/completed_goal_card.dart';
import '../../models/day_status.dart';
import '../../widgets/deadlines/cards/study_consistency_card.dart';

class DashboardTemplate extends StatelessWidget {
  final Map<int, DayStatus> weeklyConsistency;
  final int missedSessionsCount;
  final int studyStreak;
  final List<Goal> overdueGoals;
  final List<Goal> upcomingGoals;
  final List<Goal> completedGoals;
  final Map<String, int> goalsTimeSpent;
  final Function(Goal) onGoalTap;

  const DashboardTemplate({
    super.key,
    required this.weeklyConsistency,
    required this.missedSessionsCount,
    required this.studyStreak,
    required this.overdueGoals,
    required this.upcomingGoals,
    required this.completedGoals,
    required this.goalsTimeSpent,
    required this.onGoalTap,
  });

  Widget _sectionLabel({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleText = isDark ? Colors.grey[500]! : Colors.grey[500]!;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: subtleText,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      children: [
        // Study Consistency
        StudyConsistencyCard(
          weeklyConsistency: weeklyConsistency,
          missedSessionsCount: missedSessionsCount,
          studyStreak: studyStreak,
        ),

        // Overdue section
        if (overdueGoals.isNotEmpty) ...[
          const SizedBox(height: 24),
          _sectionLabel(
            context: context,
            icon: Icons.error_outline,
            iconColor: AppColors.overdue,
            iconBg: isDark
                ? AppColors.overdue.withValues(alpha: 0.1)
                : const Color(0xFFFFEDED),
            label: context.l10n.dashboardSectionOverdue,
          ),
          const SizedBox(height: 12),
          ...overdueGoals.map(
            (goal) => OverdueGoalCard(
              goal: goal,
              onTap: () => onGoalTap(goal),
            ),
          ),
        ],

        // Upcoming section
        if (upcomingGoals.isNotEmpty) ...[
          const SizedBox(height: 24),
          _sectionLabel(
            context: context,
            icon: Icons.calendar_month,
            iconColor: AppColors.iconPurple,
            iconBg: AppColors.iconBgPurple,
            label: context.l10n.dashboardSectionUpcoming,
          ),
          const SizedBox(height: 12),
          ...upcomingGoals.map(
            (goal) => UpcomingGoalCard(
              goal: goal,
              timeSpent: goalsTimeSpent[goal.id] ?? 0,
              onTap: () => onGoalTap(goal),
            ),
          ),
        ],

        // Completed section
        if (completedGoals.isNotEmpty) ...[
          const SizedBox(height: 24),
          _sectionLabel(
            context: context,
            icon: Icons.check_circle_outline,
            iconColor: AppColors.completed,
            iconBg: isDark
                ? AppColors.completed.withValues(alpha: 0.1)
                : const Color(0xFFECFDF5),
            label: context.l10n.dashboardSectionCompleted,
          ),
          const SizedBox(height: 12),
          ...completedGoals.map(
            (goal) => CompletedGoalCard(
              goal: goal,
              onTap: () => onGoalTap(goal),
            ),
          ),
        ],

        // Empty state
        if (overdueGoals.isEmpty &&
            upcomingGoals.isEmpty &&
            completedGoals.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.dashboardEmptyTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.dashboardEmptySubtitle,
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
