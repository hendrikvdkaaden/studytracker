import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onMarkComplete;
  final bool isCompleted;

  const ActionButtons({
    super.key,
    required this.onMarkComplete,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onMarkComplete,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0DF2DF),
          foregroundColor: const Color(0xFF102221),
          elevation: 0,
          shadowColor: const Color(0xFF0DF2DF).withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.check_circle_outline,
              color: const Color(0xFF102221),
            ),
            const SizedBox(width: 8),
            Text(
              isCompleted ? 'Mark as Incomplete' : 'Mark as Completed',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102221),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

