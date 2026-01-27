import 'package:flutter/material.dart';

class CompleteButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onPressed;

  const CompleteButton({
    super.key,
    required this.isCompleted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          isCompleted ? Icons.refresh : Icons.check_circle,
        ),
        label: Text(
          isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? Colors.grey : Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
