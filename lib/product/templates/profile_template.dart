import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/profile/subjects_section.dart';

class ProfileTemplate extends StatelessWidget {
  final String userName;
  final int sessionReminderMinutes;
  final int deadlineReminderDays;
  final int themeModeIndex;
  final String appVersion;
  final List<SubjectData> subjects;
  final String schoolName;
  final VoidCallback onEditName;
  final VoidCallback onSessionReminderTap;
  final VoidCallback onDeadlineReminderTap;
  final VoidCallback onThemeTap;
  final VoidCallback onDeleteSessions;
  final VoidCallback onDeleteEverything;
  final VoidCallback onAddSubject;
  final ValueChanged<SubjectData> onDeleteSubject;

  const ProfileTemplate({
    super.key,
    required this.userName,
    required this.sessionReminderMinutes,
    required this.deadlineReminderDays,
    required this.themeModeIndex,
    required this.appVersion,
    required this.subjects,
    required this.schoolName,
    required this.onEditName,
    required this.onSessionReminderTap,
    required this.onDeadlineReminderTap,
    required this.onThemeTap,
    required this.onDeleteSessions,
    required this.onDeleteEverything,
    required this.onAddSubject,
    required this.onDeleteSubject,
  });

  String get _initials {
    final trimmed = userName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  String _themeModeLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (themeModeIndex) {
      case 1:
        return l10n.profileThemeLight;
      case 2:
        return l10n.profileThemeDark;
      default:
        return l10n.profileThemeSystem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        // Profile Header
        _buildProfileHeader(context, isDark),
        const SizedBox(height: 24),

        // Subjects Section
        _buildSectionLabel(l10n.profileSectionSubjects, isDark),
        const SizedBox(height: 8),
        SubjectsSection(
          subjects: subjects,
          onAddSubject: onAddSubject,
          onDeleteSubject: onDeleteSubject,
        ),
        const SizedBox(height: 24),

        // Notifications Section
        _buildSectionLabel(l10n.profileSectionNotifications, isDark),
        const SizedBox(height: 8),
        _buildGroupCard(
          context,
          isDark,
          children: [
            _buildSettingsRow(
              context,
              isDark,
              icon: Icons.notifications_outlined,
              iconColor: AppColors.primary,
              label: l10n.profileSessionReminderLabel,
              value: l10n.profileSessionReminderFormat(sessionReminderMinutes),
              onTap: onSessionReminderTap,
            ),
            _buildDivider(isDark),
            _buildSettingsRow(
              context,
              isDark,
              icon: Icons.event_note_outlined,
              iconColor: const Color(0xFF8B5CF6),
              label: l10n.profileDeadlineReminderLabel,
              value: l10n.profileDeadlineReminderFormat(deadlineReminderDays),
              onTap: onDeadlineReminderTap,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Appearance Section
        _buildSectionLabel(l10n.profileSectionAppearance, isDark),
        const SizedBox(height: 8),
        _buildGroupCard(
          context,
          isDark,
          children: [
            _buildSettingsRow(
              context,
              isDark,
              icon: Icons.palette_outlined,
              iconColor: const Color(0xFF10B981),
              label: l10n.profileThemeLabel,
              value: _themeModeLabel(context),
              onTap: onThemeTap,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Data Section
        _buildSectionLabel(l10n.profileSectionData, isDark),
        const SizedBox(height: 8),
        _buildGroupCard(
          context,
          isDark,
          children: [
            _buildSettingsRow(
              context,
              isDark,
              icon: Icons.timer_off_outlined,
              iconColor: const Color(0xFFEF4444),
              label: l10n.profileDeleteSessionsLabel,
              labelColor: const Color(0xFFEF4444),
              onTap: onDeleteSessions,
              showChevron: false,
            ),
            _buildDivider(isDark),
            _buildSettingsRow(
              context,
              isDark,
              icon: Icons.delete_outline,
              iconColor: const Color(0xFFEF4444),
              label: l10n.profileDeleteEverythingLabel,
              labelColor: const Color(0xFFEF4444),
              onTap: onDeleteEverything,
              showChevron: false,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // App version
        Center(
          child: Text(
            l10n.profileVersionLabel(appVersion),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF135BEC), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.isEmpty ? context.l10n.profileNamePlaceholder : userName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: userName.isEmpty
                        ? (isDark ? Colors.grey[500] : Colors.grey[400])
                        : (isDark ? Colors.white : AppColors.darkBackground),
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onEditName,
                  child: Text(
                    schoolName.isEmpty ? context.l10n.profileSchoolNamePlaceholder : schoolName,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Edit button
          IconButton(
            onPressed: onEditName,
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    bool isDark, {
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.getBorderColor(context),
          ),
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String label,
    String? value,
    Color? labelColor,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor ??
                      (isDark ? Colors.white : AppColors.darkBackground),
                ),
              ),
            ),
            // Value + chevron
            if (value != null) ...[
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 66),
      child: Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06),
      ),
    );
  }
}
