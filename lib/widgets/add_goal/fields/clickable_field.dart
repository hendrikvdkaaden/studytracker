import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ClickableField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final String displayText;
  final IconData icon;
  final Color? iconBg;
  final Color? iconColor;
  final VoidCallback onTap;

  const ClickableField({
    super.key,
    required this.label,
    this.subtitle,
    required this.displayText,
    required this.icon,
    this.iconBg,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionBg =
        isDark ? AppColors.darkFieldBackground : AppColors.lightFieldBackground;
    final subtleText = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? (iconColor ?? AppColors.primary).withValues(alpha: 0.15)
                    : (iconBg ?? const Color(0xFFEFF6FF)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17,
                  color: iconColor ?? AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: subtleText,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 11, color: subtleText),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: sectionBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: subtleText, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
