import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class EditProfileResult {
  final String name;
  final String schoolName;

  const EditProfileResult({required this.name, required this.schoolName});
}

class EditNameDialog extends StatefulWidget {
  final String initialName;
  final String initialSchoolName;

  const EditNameDialog({
    super.key,
    required this.initialName,
    this.initialSchoolName = '',
  });

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _schoolController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _schoolFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _schoolController = TextEditingController(text: widget.initialSchoolName);
    _nameFocusNode = FocusNode();
    _schoolFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _nameFocusNode.dispose();
    _schoolFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      EditProfileResult(
        name: _nameController.text.trim(),
        schoolName: _schoolController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBackground = isDark ? AppColors.darkCard : AppColors.lightCard;
    final fieldFill = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
    final labelColor = Colors.grey[500]!;
    final titleColor = isDark ? AppColors.lightText : AppColors.darkText;
    final subtitleColor = labelColor;
    final handleColor = isDark
        ? const Color(0xFF475569)
        : const Color(0xFFCBD5E1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: sheetBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 48,
                height: 6,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "This is how you'll appear to your study group.",
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Display Name field
            _FieldLabel(label: 'DISPLAY NAME', color: labelColor),
            const SizedBox(height: 8),
            _SheetTextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              hintText: 'Enter your name',
              fieldFill: fieldFill,
              isDark: isDark,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _schoolFocusNode.requestFocus(),
            ),

            const SizedBox(height: 24),

            // School Name field
            _FieldLabel(label: 'SCHOOL NAME', color: labelColor),
            const SizedBox(height: 8),
            _SheetTextField(
              controller: _schoolController,
              focusNode: _schoolFocusNode,
              hintText: 'Enter school name',
              fieldFill: fieldFill,
              isDark: isDark,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: 32),

            // Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Update button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.calendarAccent,
                      foregroundColor: AppColors.darkBackground,
                      elevation: 4,
                      shadowColor: AppColors.calendarAccent.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel button
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _FieldLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        color: color,
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final Color fieldFill;
  final bool isDark;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _SheetTextField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.fieldFill,
    required this.isDark,
    required this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.lightText : AppColors.darkText;
    final hintTextColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.words,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: TextStyle(
        fontSize: 16,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: hintTextColor,
          fontSize: 16,
        ),
        filled: true,
        fillColor: fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.calendarAccent.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
