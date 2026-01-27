import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  final bool isCompleted;
  final bool isOverdue;
  final int daysLeft;
  final Color color;

  const StatusBanner({
    super.key,
    required this.isCompleted,
    required this.isOverdue,
    required this.daysLeft,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _buildBanner(
        color: Colors.green,
        icon: Icons.check_circle,
        text: 'Completed',
      );
    }

    if (isOverdue) {
      return _buildBanner(
        color: Colors.red,
        icon: Icons.warning,
        text: '${daysLeft.abs()} days overdue',
      );
    }

    return _buildBanner(
      color: color,
      icon: Icons.calendar_today,
      text: '$daysLeft days left',
    );
  }

  Widget _buildBanner({
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
