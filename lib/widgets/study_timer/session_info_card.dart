import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class SessionInfoCard extends StatelessWidget {
  final int targetMinutes;
  final int elapsedSeconds;

  const SessionInfoCard({
    super.key,
    required this.targetMinutes,
    required this.elapsedSeconds,
  });

  String _formatElapsedTime() {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatTargetTime() {
    final hours = targetMinutes ~/ 60;
    final minutes = targetMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours Hours';
    } else if (hours > 0) {
      return '$hours Hours';
    }
    return '$minutes Minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SESSION GOAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTargetTime(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: context.colors.divider,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ELAPSED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatElapsedTime(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
