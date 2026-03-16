import 'package:flutter/material.dart';
import '../utils/l10n_extension.dart';

/// Service for displaying goal-related dialogs
class GoalDialogService {
  /// Shows a confirmation dialog for deleting a goal
  static Future<bool> showDeleteConfirmation(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.goalDialogDeleteTitle),
        content: Text(l10n.goalDialogDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.btnCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.btnDelete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows a success snackbar
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0DF2DF),
      ),
    );
  }
}
