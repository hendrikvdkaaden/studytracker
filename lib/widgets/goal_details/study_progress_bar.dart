import 'package:flutter/material.dart';

class StudyProgressBar extends StatelessWidget {
  final double progress;
  final Color progressColor;

  const StudyProgressBar({
    super.key,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  progressColor,
                  progressColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: progressColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
