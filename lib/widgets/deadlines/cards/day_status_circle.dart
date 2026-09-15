import 'package:flutter/material.dart';
import '../../../models/day_status.dart';
import '../../../theme/app_theme_extension.dart';

class DayStatusCircle extends StatelessWidget {
  final DayStatus status;

  const DayStatusCircle({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final emptyBorder = Border.all(
      color: context.colors.border,
      width: 2,
    );
    final emptyColor = context.colors.isDark
        ? Colors.black.withValues(alpha: 0.2)
        : Colors.white.withValues(alpha: 0.5);

    switch (status) {
      case DayStatus.completed:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.colors.accentStrong,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        );
      case DayStatus.missed:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.colors.isDark
                  ? Colors.red.shade900.withValues(alpha: 0.5)
                  : Colors.red.shade200,
              width: 2,
            ),
            color: context.colors.isDark
                ? Colors.red.shade900.withValues(alpha: 0.1)
                : Colors.red.shade50.withValues(alpha: 0.5),
          ),
          child: Icon(Icons.close, color: Colors.red.shade400, size: 16),
        );
      case DayStatus.notPlanned:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: emptyBorder,
            color: emptyColor,
          ),
        );
      case DayStatus.pastNoSession:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: emptyBorder,
            color: emptyColor,
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 2,
              color: context.colors.textTertiary,
            ),
          ),
        );
    }
  }
}
