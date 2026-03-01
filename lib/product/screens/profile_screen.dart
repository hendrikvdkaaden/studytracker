import 'package:flutter/material.dart';
import '../../services/hive_service.dart';
import '../../services/settings_service.dart';
import '../../services/study_session_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/profile/edit_name_dialog.dart';
import '../templates/profile_template.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const ProfileScreen({super.key, this.onThemeChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  int _sessionReminderMinutes = 15;
  int _deadlineReminderDays = 1;
  int _themeModeIndex = 0;
  static const String _appVersion = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _userName = SettingsService.userName;
    _sessionReminderMinutes = SettingsService.sessionReminderMinutes;
    _deadlineReminderDays = SettingsService.deadlineReminderDays;
    _themeModeIndex = SettingsService.themeModeIndex;
  }

  Future<void> _editName() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => EditNameDialog(initialName: _userName),
    );

    if (result != null && mounted) {
      await SettingsService.setUserName(result);
      setState(() => _userName = result);
    }
  }

  Future<void> _pickSessionReminder() async {
    await _showPickerSheet(
      title: 'Session reminder',
      subtitle: 'How long before a session should we remind you?',
      options: [5, 10, 15, 30, 60],
      currentValue: _sessionReminderMinutes,
      labelBuilder: (v) => v < 60 ? '$v minutes before' : '${v ~/ 60}h before',
      onSelected: (v) async {
        await SettingsService.setSessionReminderMinutes(v);
        setState(() => _sessionReminderMinutes = v);
      },
    );
  }

  Future<void> _pickDeadlineReminder() async {
    await _showPickerSheet(
      title: 'Deadline reminder',
      subtitle: 'How many days before a deadline should we remind you?',
      options: [1, 2, 3, 5, 7],
      currentValue: _deadlineReminderDays,
      labelBuilder: (v) => v == 1 ? '1 day before' : '$v days before',
      onSelected: (v) async {
        await SettingsService.setDeadlineReminderDays(v);
        setState(() => _deadlineReminderDays = v);
      },
    );
  }

  Future<void> _pickTheme() async {
    final labels = ['System', 'Light', 'Dark'];
    await _showPickerSheet(
      title: 'Appearance',
      options: [0, 1, 2],
      currentValue: _themeModeIndex,
      labelBuilder: (i) => labels[i],
      onSelected: (i) async {
        await SettingsService.setThemeModeIndex(i);
        setState(() => _themeModeIndex = i);
        widget.onThemeChanged?.call();
      },
    );
  }

  Future<void> _showPickerSheet<T>({
    required String title,
    String? subtitle,
    required List<T> options,
    required T currentValue,
    required String Function(T) labelBuilder,
    required Future<void> Function(T) onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...options.map((option) {
                final isSelected = option == currentValue;
                return ListTile(
                  title: Text(
                    labelBuilder(option),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await onSelected(option);
                  },
                );
              }),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteSessions() async {
    final confirmed = await _showDestructiveConfirmation(
      title: 'Delete all study sessions?',
      body: 'This will permanently delete all your study sessions. Your goals will remain intact.',
      confirmLabel: 'Delete sessions',
    );
    if (confirmed == true && mounted) {
      await StudySessionRepository().clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All study sessions deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteEverything() async {
    final confirmed = await _showDestructiveConfirmation(
      title: 'Delete everything?',
      body: 'This will permanently delete all your goals and study sessions. This action cannot be undone.',
      confirmLabel: 'Delete everything',
    );
    if (confirmed == true && mounted) {
      await HiveService.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool?> _showDestructiveConfirmation({
    required String title,
    required String body,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileTemplate(
      userName: _userName,
      sessionReminderMinutes: _sessionReminderMinutes,
      deadlineReminderDays: _deadlineReminderDays,
      themeModeIndex: _themeModeIndex,
      appVersion: _appVersion,
      onEditName: _editName,
      onSessionReminderTap: _pickSessionReminder,
      onDeadlineReminderTap: _pickDeadlineReminder,
      onThemeTap: _pickTheme,
      onDeleteSessions: _confirmDeleteSessions,
      onDeleteEverything: _confirmDeleteEverything,
    );
  }
}
