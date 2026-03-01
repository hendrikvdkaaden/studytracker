import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../widgets/goal_details_modern/info/goal_info_card.dart';
import '../../widgets/goal_details_modern/info/deadline_card.dart';
import '../../widgets/goal_details_modern/progress/progress_section_header.dart';
import '../../widgets/goal_details_modern/progress/progress_circle.dart';
import '../../widgets/goal_details_modern/actions/action_buttons.dart';
import '../../widgets/goal_details_modern/sessions/planned_sessions_section.dart';

/// Layout template for the goal details screen
class GoalDetailsTemplate extends StatelessWidget {
  final Goal goal;
  final int timeSpent;
  final List<StudySession> plannedSessions;
  final VoidCallback onEditProgress;
  final VoidCallback onMarkComplete;
  final VoidCallback onAddSession;
  final VoidCallback onEditInfo;
  final VoidCallback onEditDeadline;

  const GoalDetailsTemplate({
    super.key,
    required this.goal,
    required this.timeSpent,
    required this.plannedSessions,
    required this.onEditProgress,
    required this.onMarkComplete,
    required this.onAddSession,
    required this.onEditInfo,
    required this.onEditDeadline,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GoalInfoCard(goal: goal, onTap: onEditInfo),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DeadlineCard(goal: goal, onTap: onEditDeadline),
          ),
          PlannedSessionsSection(
            sessions: plannedSessions,
            onAddSession: onAddSession,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: ProgressSectionHeader(onEdit: onEditProgress),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProgressCircle(
              timeSpent: timeSpent,
              targetTime: goal.studyTime,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: ActionButtons(
              onMarkComplete: onMarkComplete,
              isCompleted: goal.isCompleted,
            ),
          ),
        ],
      ),
    );
  }
}
