import 'package:flutter/material.dart';
import '../../../theme/app_theme_extension.dart';

class MonthNavigation extends StatelessWidget {
  final DateTime focusedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  const MonthNavigation({
    super.key,
    required this.focusedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavigationButton(
            icon: Icons.chevron_left,
            onPressed: onPreviousMonth,
          ),
          Text(
            _formatMonthYear(focusedMonth),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          _buildNavigationButton(
            icon: Icons.chevron_right,
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  String _formatMonthYear(DateTime date) {
    return '${_months[date.month - 1]} ${date.year}';
  }
}
