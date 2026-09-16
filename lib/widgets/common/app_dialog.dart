import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';

/// Shows a confirmation dialog styled like the rest of the app.
///
/// Returns true when confirmed, false on cancel or dismiss — never null, so
/// callers can use the result directly.
Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  IconData icon = Icons.help_outline,
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _AppDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel ?? ctx.l10n.btnCancel,
      icon: icon,
      isDestructive: isDestructive,
    ),
  );
  return result ?? false;
}

/// Shows a message dialog with a single dismiss button.
Future<void> showAppMessageDialog({
  required BuildContext context,
  required String message,
  String? title,
  IconData icon = Icons.info_outline,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _AppDialog(
      title: title,
      message: message,
      confirmLabel: ctx.l10n.btnClose,
      icon: icon,
    ),
  );
}

class _AppDialog extends StatelessWidget {
  final String? title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final IconData icon;
  final bool isDestructive;

  const _AppDialog({
    required this.message,
    required this.confirmLabel,
    this.title,
    this.cancelLabel,
    this.icon = Icons.help_outline,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = isDestructive ? AppColors.overdue : context.colors.accent;

    return Dialog(
      backgroundColor: colors.modalBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.statusTint(accent,
                    darkAlpha: 0.18, lightAlpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: accent),
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: colors.sectionBackground,
                        foregroundColor: colors.textSecondary,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          cancelLabel!,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDestructive
                            ? [AppColors.overdue, AppColors.overdue]
                            : [context.colors.accent, context.colors.accentStrong],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(0, 50),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          confirmLabel,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
