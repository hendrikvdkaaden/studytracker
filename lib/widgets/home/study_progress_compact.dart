import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../services/study_session_repository.dart';

class StudyProgressCompact extends StatelessWidget {
  final Goal goal;

  const StudyProgressCompact({
    super.key,
    required this.goal,
  });

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final studySessionRepo = StudySessionRepository();
    final totalStudied = studySessionRepo.getTotalStudyTimeForGoal(goal.id);
    final targetTime = goal.studyTime;
    final progress = targetTime > 0 ? (totalStudied / targetTime).clamp(0.0, 1.0) : 0.0;
    final progressColor = progress >= 1.0 ? Colors.green : Colors.teal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(totalStudied),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
            Text(
              _formatTime(targetTime),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      progressColor,
                      progressColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
