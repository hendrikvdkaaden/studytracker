import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class CalendarSectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const CalendarSectionHeader({
    super.key,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              // The tint stays on the strong mid-tone; only the numeral on
              // top of it moves to accent, which is readable at 12px.
              color: context.colors.accentStrong.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                // See date_header: the accent is only readable at this size
                // on a light surface.
                color: context.colors.isDark
                    ? context.colors.textPrimary
                    : context.colors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
