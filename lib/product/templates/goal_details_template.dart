import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../widgets/goal_details_modern/goal_info_card.dart';
import '../../widgets/goal_details_modern/deadline_card.dart';
import '../../widgets/goal_details_modern/progress_section_header.dart';
import '../../widgets/goal_details_modern/progress_circle.dart';
import '../../widgets/goal_details_modern/action_buttons.dart';

/// Layout template for the goal details screen
class GoalDetailsTemplate extends StatelessWidget {
  final Goal goal;
  final int timeSpent;
  final VoidCallback onEditProgress;
  final VoidCallback onMarkComplete;

  const GoalDetailsTemplate({
    super.key,
    required this.goal,
    required this.timeSpent,
    required this.onEditProgress,
    required this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoalInfoSection(),
          _buildDeadlineSection(),
          _buildProgressSection(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildGoalInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GoalInfoCard(goal: goal),
    );
  }

  Widget _buildDeadlineSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DeadlineCard(goal: goal),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: ActionButtons(
        onMarkComplete: onMarkComplete,
        isCompleted: goal.isCompleted,
      ),
    );
  }
}
