import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SessionProgressBar extends StatelessWidget {
  final int elapsedSeconds;
  final int targetMinutes;

  const SessionProgressBar({
    super.key,
    required this.elapsedSeconds,
    required this.targetMinutes,
  });

  double get _progressPercentage {
    if (targetMinutes == 0) return 0;
    final targetSeconds = targetMinutes * 60;
    final progress = (elapsedSeconds / targetSeconds).clamp(0.0, 1.0);
    return progress;
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (_progressPercentage * 100).toInt();
    final targetSeconds = targetMinutes * 60;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Session Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              '$percentage% Completed',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.calendarAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200]?.withOpacity(0.6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: _progressPercentage,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.calendarAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_formatTime(elapsedSeconds)} of ${_formatTime(targetSeconds)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
