import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final IconData? icon;
  final Color? iconBg;
  final Color? iconColor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.icon,
    this.iconBg,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionBg =
        isDark ? AppColors.darkFieldBackground : AppColors.lightFieldBackground;
    final subtleText = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, isDark, subtleText),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white : AppColors.darkText,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: subtleText),
            filled: true,
            fillColor: sectionBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.overdue),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  const BorderSide(color: AppColors.overdue, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color subtleText) {
    if (icon != null) {
      return Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? (iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant).withValues(alpha: 0.15)
                  : (iconBg ?? AppColors.iconBgTeal),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17,
                color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: subtleText,
            ),
          ),
        ],
      );
    }
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
        color: subtleText,
      ),
    );
  }
}
