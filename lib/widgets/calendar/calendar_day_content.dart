import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../product/screens/goal_details_screen.dart';
import '../../product/screens/study_timer_screen.dart';
import '../../services/goal_repository.dart';
import '../../theme/app_colors.dart';
import 'goals/deadline_list_item.dart';
import 'sessions/session_list_item.dart';

class CalendarDayContent extends StatefulWidget {
  final List<Goal> goals;
  final List<StudySession> sessions;
  final VoidCallback onGoalUpdated;

  const CalendarDayContent({
    super.key,
    required this.goals,
    required this.sessions,
    required this.onGoalUpdated,
  });

  @override
  State<CalendarDayContent> createState() => _CalendarDayContentState();
}

class _CalendarDayContentState extends State<CalendarDayContent> {
  final _goalRepo = GoalRepository();

  bool _isSessionCompleted(StudySession session) {
    return session.actualDuration != null &&
        session.actualDuration! >= session.duration;
  }

  void _onSessionTap(StudySession session) {
    final goal = _goalRepo.getGoalById(session.goalId);
    if (goal == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyTimerScreen(session: session, goal: goal),
      ),
    ).then((_) => widget.onGoalUpdated());
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 56,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            'No deadlines or sessions',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(
    BuildContext context,
    bool isDark,
    String title,
    IconData icon,
    Color iconColor,
    Color iconBg,
  ) {
    final subtleText = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.15) : iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: subtleText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.goals.isEmpty && widget.sessions.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 80),
      children: [
        // Deadlines Section
        if (widget.goals.isNotEmpty) ...[
          _buildSectionLabel(
            context,
            isDark,
            'Deadlines',
            Icons.calendar_month,
            AppColors.iconOrange,
            AppColors.iconBgOrange,
          ),
          ...widget.goals.map((goal) => DeadlineListItem(
                goal: goal,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalDetailsScreen(goal: goal),
                    ),
                  );
                  widget.onGoalUpdated();
                },
              )),
        ],
        // Sessions Section
        if (widget.sessions.isNotEmpty) ...[
          if (widget.goals.isNotEmpty) const SizedBox(height: 24),
          _buildSectionLabel(
            context,
            isDark,
            'Study Sessions',
            Icons.bolt,
            AppColors.iconPurple,
            AppColors.iconBgPurple,
          ),
          ...widget.sessions.map((session) {
            final goal = _goalRepo.getGoalById(session.goalId);
            if (goal == null) return const SizedBox.shrink();
            return SessionListItem(
              session: session,
              goal: goal,
              isCompleted: _isSessionCompleted(session),
              onTap: () => _onSessionTap(session),
            );
          }),
        ],
      ],
    );
  }
}
