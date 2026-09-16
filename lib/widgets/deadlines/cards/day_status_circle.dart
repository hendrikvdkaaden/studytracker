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
    final emptyColor = context.colors.emptyFill;

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
            border: Border.all(color: context.colors.missedBorder, width: 2),
            color: context.colors.missedFill,
          ),
          child: Icon(Icons.close, color: context.colors.missedIcon, size: 16),
        );
      case DayStatus.frozen:
        // Deliberately not the green tick: the day was not studied, and
        // dressing it up as completed would make the numbers untrustworthy.
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.frozenBorder, width: 2),
            color: context.colors.frozenFill,
          ),
          child: Icon(
            Icons.ac_unit,
            color: context.colors.frozenIcon,
            size: 16,
          ),
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
