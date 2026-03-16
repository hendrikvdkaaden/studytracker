import 'package:flutter/material.dart';
import '../../services/hive_service.dart';
import '../../services/settings_service.dart';
import '../../services/study_session_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/profile/add_subject_modal.dart';
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
  List<SubjectData> _subjects = [];
  String _schoolName = '';
  static const String _appVersion = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _userName = SettingsService.userName;
    _sessionReminderMinutes = SettingsService.sessionReminderMinutes;
    _deadlineReminderDays = SettingsService.deadlineReminderDays;
    _themeModeIndex = SettingsService.themeModeIndex;
    _subjects = SettingsService.subjectData;
    _schoolName = SettingsService.schoolName;
  }

  Future<void> _editProfile() async {
    final result = await showModalBottomSheet<EditProfileResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: EditNameDialog(
          initialName: _userName,
          initialSchoolName: _schoolName,
        ),
      ),
    );

    if (result != null && mounted) {
      await SettingsService.setUserName(result.name);
      await SettingsService.setSchoolName(result.schoolName);
      setState(() {
        _userName = result.name;
        _schoolName = result.schoolName;
      });
    }
  }

  Future<void> _addSubject() async {
    final result = await showModalBottomSheet<SubjectData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddSubjectModal(),
    );
    if (result != null && mounted) {
      final updated = [..._subjects, result];
      await SettingsService.setSubjectData(updated);
      setState(() => _subjects = updated);
    }
  }

  Future<void> _deleteSubject(SubjectData subject) async {
    final l10n = context.l10n;
    final confirmed = await _showDestructiveConfirmation(
      title: l10n.profileRemoveSubjectTitle,
      body: l10n.profileRemoveSubjectBody(subject.name),
      confirmLabel: l10n.profileRemoveSubjectConfirm,
    );
    if (confirmed == true && mounted) {
      final updated = _subjects.where((s) => s.name != subject.name).toList();
      await SettingsService.setSubjectData(updated);
      setState(() => _subjects = updated);
    }
  }

  Future<void> _pickSessionReminder() async {
    final l10n = context.l10n;
    await _showPickerSheet(
      title: l10n.profilePickerSessionTitle,
      subtitle: l10n.profilePickerSessionSubtitle,
      options: [5, 10, 15, 30, 60],
      currentValue: _sessionReminderMinutes,
      labelBuilder: (v) => l10n.profilePickerSessionOptionFormat(v),
      onSelected: (v) async {
        await SettingsService.setSessionReminderMinutes(v);
        setState(() => _sessionReminderMinutes = v);
      },
    );
  }

  Future<void> _pickDeadlineReminder() async {
    final l10n = context.l10n;
    await _showPickerSheet(
      title: l10n.profilePickerDeadlineTitle,
      subtitle: l10n.profilePickerDeadlineSubtitle,
      options: [1, 2, 3, 5, 7],
      currentValue: _deadlineReminderDays,
      labelBuilder: (v) => l10n.profilePickerDeadlineOptionFormat(v),
      onSelected: (v) async {
        await SettingsService.setDeadlineReminderDays(v);
        setState(() => _deadlineReminderDays = v);
      },
    );
  }

  Future<void> _pickTheme() async {
    final l10n = context.l10n;
    final labels = [l10n.profileThemeSystem, l10n.profileThemeLight, l10n.profileThemeDark];
    await _showPickerSheet(
      title: l10n.profilePickerThemeTitle,
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
    final l10n = context.l10n;
    final confirmed = await _showDestructiveConfirmation(
      title: l10n.profileDeleteSessionsTitle,
      body: l10n.profileDeleteSessionsBody,
      confirmLabel: l10n.profileDeleteSessionsConfirm,
    );
    if (confirmed == true && mounted) {
      await StudySessionRepository().clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.profileDeleteSessionsSnack),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteEverything() async {
    final l10n = context.l10n;
    final confirmed = await _showDestructiveConfirmation(
      title: l10n.profileDeleteEverythingTitle,
      body: l10n.profileDeleteEverythingBody,
      confirmLabel: l10n.profileDeleteEverythingConfirm,
    );
    if (confirmed == true && mounted) {
      await HiveService.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.profileDeleteEverythingSnack),
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
    final cancelLabel = context.l10n.btnCancel;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
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
      subjects: _subjects,
      schoolName: _schoolName,
      onEditName: _editProfile,
      onSessionReminderTap: _pickSessionReminder,
      onDeadlineReminderTap: _pickDeadlineReminder,
      onThemeTap: _pickTheme,
      onDeleteSessions: _confirmDeleteSessions,
      onDeleteEverything: _confirmDeleteEverything,
      onAddSubject: _addSubject,
      onDeleteSubject: _deleteSubject,
    );
  }
}

