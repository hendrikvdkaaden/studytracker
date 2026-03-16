import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../models/study_session.dart';
import '../../services/settings_service.dart';
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
  final void Function(StudySession session) onEditSession;
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
    required this.onEditSession,
    required this.onEditInfo,
    required this.onEditDeadline,
  });

  @override
  Widget build(BuildContext context) {
    final subjectColor = SettingsService.colorForSubject(goal.subject);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GoalInfoCard(goal: goal, onTap: onEditInfo, accentColor: subjectColor),
          const SizedBox(height: 24),
          DeadlineCard(goal: goal, onTap: onEditDeadline),
          const SizedBox(height: 24),
          PlannedSessionsSection(
            sessions: plannedSessions,
            goalTitle: goal.title,
            onAddSession: onAddSession,
            onEditSession: onEditSession,
          ),
          const SizedBox(height: 24),
          ProgressSectionHeader(onEdit: onEditProgress),
          const SizedBox(height: 10),
          ProgressCircle(
            timeSpent: timeSpent,
            targetTime: goal.studyTime,
            accentColor: subjectColor,
          ),
          const SizedBox(height: 32),
          ActionButtons(
            onMarkComplete: onMarkComplete,
            isCompleted: goal.isCompleted,
          ),
        ],
      ),
    );
  }
}
