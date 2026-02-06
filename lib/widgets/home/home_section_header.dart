import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final int? remainingCount;
  final int? completedCount;
  final int? totalCount;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.remainingCount,
    this.completedCount,
    this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (remainingCount != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.overdue.withOpacity(0.2)
                  : AppColors.overdue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AppColors.overdue.withOpacity(0.3)
                    : AppColors.overdue.withOpacity(0.2),
              ),
            ),
            child: Text(
              '$remainingCount REMAINING',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.overdue,
                letterSpacing: 0.3,
              ),
            ),
          ),
        if (completedCount != null && totalCount != null)
          Row(
            children: [
              Text(
                'DONE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$completedCount/$totalCount',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
