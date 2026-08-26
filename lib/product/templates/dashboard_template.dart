import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/deadlines/cards/overdue_goal_card.dart';
import '../../widgets/deadlines/cards/upcoming_goal_card.dart';
import '../../widgets/deadlines/cards/completed_goal_card.dart';
import '../../models/day_status.dart';
import '../../widgets/deadlines/cards/study_consistency_card.dart';
import '../../widgets/deadlines/goal_carousel.dart';

class DashboardTemplate extends StatelessWidget {
  final Map<int, DayStatus> weeklyConsistency;
  final int missedSessionsCount;
  final int studyStreak;
  final List<Goal> overdueGoals;
  final List<Goal> upcomingGoals;
  final List<Goal> completedGoals;
  final Map<String, int> goalsTimeSpent;
  final Function(Goal) onGoalTap;
  final bool completedCollapsed;
  final VoidCallback onToggleCompleted;

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
    required this.completedCollapsed,
    required this.onToggleCompleted,
  });

  /// Inset applied per item rather than to the list, so a carousel can scroll
  /// its cards all the way to the screen edge.
  static const double _sidePadding = 24;

  Widget _inset(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
        child: child,
      );

  Widget _sectionLabel({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    Widget? trailing,
  }) {
    final subtleText = context.colors.textSecondary;

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
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: subtleText,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }

  /// Text button that folds the completed section away and back.
  Widget _toggleButton(BuildContext context) {
    return TextButton(
      onPressed: onToggleCompleted,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: context.colors.textSecondary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            completedCollapsed
                ? context.l10n.dashboardShowCompleted
                : context.l10n.dashboardHideCompleted,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            completedCollapsed ? Icons.expand_more : Icons.expand_less,
            size: 16,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
      children: [
        // Study Consistency
        _inset(
          StudyConsistencyCard(
            weeklyConsistency: weeklyConsistency,
            missedSessionsCount: missedSessionsCount,
            studyStreak: studyStreak,
          ),
        ),

        // Overdue section
        if (overdueGoals.isNotEmpty) ...[
          const SizedBox(height: 24),
          _inset(
            _sectionLabel(
              context: context,
              icon: Icons.error_outline,
              iconColor: AppColors.overdue,
              iconBg: context.colors.isDark
                  ? AppColors.overdue.withValues(alpha: 0.1)
                  : const Color(0xFFFFEDED),
              label: context.l10n.dashboardSectionOverdue,
            ),
          ),
          const SizedBox(height: 12),
          GoalCarousel(
            horizontalPadding: _sidePadding,
            cards: [
              for (final goal in overdueGoals)
                OverdueGoalCard(
                  goal: goal,
                  onTap: () => onGoalTap(goal),
                ),
            ],
          ),
        ],

        // Upcoming section
        if (upcomingGoals.isNotEmpty) ...[
          const SizedBox(height: 24),
          _inset(
            _sectionLabel(
              context: context,
              icon: Icons.calendar_month,
              iconColor: AppColors.iconPurple,
              iconBg: context.colors.isDark
                  ? AppColors.iconBgPurple.withValues(alpha: 0.1)
                  : const Color(0xFFFFEDED),
              label: context.l10n.dashboardSectionUpcoming,
            ),
          ),
          const SizedBox(height: 12),
          GoalCarousel(
            horizontalPadding: _sidePadding,
            cards: [
              for (final goal in upcomingGoals)
                UpcomingGoalCard(
                  goal: goal,
                  timeSpent: goalsTimeSpent[goal.id] ?? 0,
                  onTap: () => onGoalTap(goal),
                ),
            ],
          ),
        ],

        // Completed section
        if (completedGoals.isNotEmpty) ...[
          const SizedBox(height: 24),
          _inset(
            _sectionLabel(
              context: context,
              icon: Icons.check_circle_outline,
              iconColor: AppColors.completed,
              iconBg: context.colors.isDark
                  ? AppColors.completed.withValues(alpha: 0.1)
                  : const Color(0xFFECFDF5),
              label: context.l10n.dashboardSectionCompleted,
              trailing: _toggleButton(context),
            ),
          ),
          if (!completedCollapsed) ...[
            const SizedBox(height: 12),
            GoalCarousel(
              horizontalPadding: _sidePadding,
              cards: [
                for (final goal in completedGoals)
                  CompletedGoalCard(
                    goal: goal,
                    onTap: () => onGoalTap(goal),
                  ),
              ],
            ),
          ],
        ],

        // Empty state
        if (overdueGoals.isEmpty &&
            upcomingGoals.isEmpty &&
            completedGoals.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                _sidePadding, 48, _sidePadding, 0),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.dashboardEmptyTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.dashboardEmptySubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
