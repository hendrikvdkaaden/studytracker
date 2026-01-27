import 'package:flutter/material.dart';
import '../../models/goal.dart';
import '../../services/study_session_repository.dart';
import 'add_study_time_dialog.dart';
import 'study_progress_header.dart';
import 'study_progress_bar.dart';
import 'edit_time_button.dart';

class StudyTimeCard extends StatefulWidget {
  final Goal goal;

  const StudyTimeCard({
    super.key,
    required this.goal,
  });

  @override
  State<StudyTimeCard> createState() => _StudyTimeCardState();
}

class _StudyTimeCardState extends State<StudyTimeCard> {
  void _showEditTimeDialog(int currentTotalMinutes) {
    showEditStudyTimeDialog(
      context,
      widget.goal.id,
      currentTotalMinutes,
      () {
        setState(() {});
      },
    );
  }

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
    final totalStudied = studySessionRepo.getTotalStudyTimeForGoal(widget.goal.id);
    final targetTime = widget.goal.studyTime;
    final progress = targetTime > 0 ? (totalStudied / targetTime).clamp(0.0, 1.0) : 0.0;
    final progressColor = progress >= 1.0 ? Colors.green : Colors.teal;
    final progressPercentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            progressColor.withValues(alpha: 0.05),
            progressColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: progressColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudyProgressHeader(
            progressColor: progressColor,
            progressPercentage: progressPercentage,
            timeText: '${_formatTime(totalStudied)} of ${_formatTime(targetTime)}',
          ),
          const SizedBox(height: 16),
          StudyProgressBar(
            progress: progress,
            progressColor: progressColor,
          ),
          const SizedBox(height: 16),
          EditTimeButton(
            onPressed: () => _showEditTimeDialog(totalStudied),
            color: progressColor,
          ),
        ],
      ),
    );
  }
}
