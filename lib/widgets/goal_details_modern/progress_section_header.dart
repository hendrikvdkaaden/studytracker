import 'package:flutter/material.dart';

/// Header for the progress section with edit button
class ProgressSectionHeader extends StatelessWidget {
  final VoidCallback onEdit;

  const ProgressSectionHeader({
    super.key,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Progress Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.015,
            color: isDark ? Colors.white : const Color(0xFF0D1C1B),
          ),
        ),
        _buildEditButton(isDark),
      ],
    );
  }

  Widget _buildEditButton(bool isDark) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF0DF2DF).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.edit,
          size: 18,
          color: isDark ? const Color(0xFF0DF2DF) : const Color(0xFF0D1C1B),
        ),
      ),
    );
  }
}
