import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/l10n_extension.dart';

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
    if (isCompleted) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton.icon(
          onPressed: onMarkComplete,
          icon: const Icon(Icons.check_circle, size: 18),
          label: Text(
            context.l10n.goalDetailsMarkIncomplete,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.completed,
            side: const BorderSide(color: AppColors.completed),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF4489FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onMarkComplete,
        icon: const Icon(Icons.check_circle_outline, size: 18),
        label: Text(
          context.l10n.goalDetailsMarkComplete,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
