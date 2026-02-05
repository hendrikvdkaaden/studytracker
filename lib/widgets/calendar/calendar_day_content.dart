import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../product/screens/goal_details_screen.dart';
import 'goals/deadline_list_item.dart';
import 'sessions/session_list_item.dart';
import 'calendar_section_header.dart';

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
  Widget _buildEmptyState() {
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
            'No deadlines or sessions',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.goals.isEmpty && widget.sessions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      children: [
        // Goals Section
        if (widget.goals.isNotEmpty) ...[
          CalendarSectionHeader(
            title: 'Deadlines',
            count: widget.goals.length,
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
          if (widget.goals.isNotEmpty) const SizedBox(height: 16),
          CalendarSectionHeader(
            title: 'Study Sessions',
            count: widget.sessions.length,
          ),
          ...widget.sessions.map((session) => SessionListItem(
                session: session,
              )),
        ],
      ],
    );
  }
}
