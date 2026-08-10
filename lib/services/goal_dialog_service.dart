import 'package:flutter/material.dart';
import '../utils/l10n_extension.dart';
import '../widgets/common/app_dialog.dart';

/// Service for displaying goal-related dialogs
class GoalDialogService {
  /// Shows a confirmation dialog for deleting a goal
  static Future<bool> showDeleteConfirmation(BuildContext context) {
    final l10n = context.l10n;
    return showAppConfirmDialog(
      context: context,
      title: l10n.goalDialogDeleteTitle,
      message: l10n.goalDialogDeleteBody,
      confirmLabel: l10n.btnDelete,
      icon: Icons.delete_outline,
      isDestructive: true,
    );
  }
}
