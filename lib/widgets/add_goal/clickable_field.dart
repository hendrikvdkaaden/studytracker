import 'package:flutter/material.dart';

class ClickableField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final String displayText;
  final IconData icon;
  final VoidCallback onTap;

  const ClickableField({
    super.key,
    required this.label,
    this.subtitle,
    required this.displayText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFCFD7E7),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  icon,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
