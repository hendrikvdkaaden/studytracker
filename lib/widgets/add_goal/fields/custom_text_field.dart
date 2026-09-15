import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme_extension.dart';

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
    final sectionBg = context.colors.fieldBackground;
    final subtleText = context.colors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, subtleText),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontSize: 15,
            color: context.colors.textPrimary,
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
                color: context.colors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: context.colors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: context.colors.accent,
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

  Widget _buildHeader(BuildContext context, Color subtleText) {
    if (icon != null) {
      return Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colors.iconChipBackground(
                iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
                iconBg ?? AppColors.iconBgTeal,
              ),
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
