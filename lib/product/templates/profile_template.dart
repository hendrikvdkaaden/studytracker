import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/common/premium_icon.dart';
import '../../widgets/profile/subjects_section.dart';

class ProfileTemplate extends StatelessWidget {
  final String userName;
  final int sessionReminderMinutes;
  final int deadlineReminderDays;
  final int themeModeIndex;
  final List<SubjectData> subjects;
  final String schoolName;
  final bool isPremium;
  final bool showPrivacyOptions;
  final bool calendarSyncEnabled;
  final bool calendarSyncBusy;
  final VoidCallback onSubscriptionTap;
  final VoidCallback onPrivacyOptions;
  final VoidCallback onCalendarSyncTap;
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
    required this.subjects,
    required this.schoolName,
    required this.isPremium,
    required this.showPrivacyOptions,
    required this.calendarSyncEnabled,
    required this.calendarSyncBusy,
    required this.onCalendarSyncTap,
    required this.onPrivacyOptions,
    required this.onSubscriptionTap,
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

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        _buildProfileHeader(context),
        const SizedBox(height: 24),
        // The premium card renders nothing for subscribers, so its trailing
        // spacer would otherwise leave a double gap.
        if (!isPremium) ...[
          _buildPremiumCard(context),
          const SizedBox(height: 24),
        ],
        _buildSectionLabel(context, l10n.profileSectionSubjects),
        const SizedBox(height: 8),
        SubjectsSection(
          subjects: subjects,
          onAddSubject: onAddSubject,
          onDeleteSubject: onDeleteSubject,
        ),
        const SizedBox(height: 24),
        _buildSectionLabel(context, l10n.profileSectionNotifications),
        const SizedBox(height: 8),
        _buildGroupCard(
          context,
          children: [
            _buildSettingsRow(
              context,
              icon: Icons.notifications_outlined,
              iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
              label: l10n.profileSessionReminderLabel,
              value: l10n.profileSessionReminderFormat(sessionReminderMinutes),
              onTap: onSessionReminderTap,
            ),
            _buildDivider(context),
            _buildSettingsRow(
              context,
              icon: Icons.event_note_outlined,
              iconColor: AppColors.iconPurple,
              label: l10n.profileDeadlineReminderLabel,
              value: l10n.profileDeadlineReminderFormat(deadlineReminderDays),
              onTap: onDeadlineReminderTap,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionLabel(context, l10n.profileSectionAppearance),
        const SizedBox(height: 8),
        _buildGroupCard(
          context,
          children: [
            _buildSettingsRow(
              context,
              icon: Icons.palette_outlined,
              iconColor: AppColors.iconGreen,
              label: l10n.profileThemeLabel,
              value: _themeModeLabel(context),
              onTap: onThemeTap,
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Consent must stay withdrawable, so this row appears wherever Google
        // reports a privacy options entry point is required (EEA and UK).
        if (showPrivacyOptions) ...[
          _buildSectionLabel(context, l10n.profileSectionPrivacy),
          const SizedBox(height: 8),
          _buildGroupCard(
            context,
            children: [
              _buildSettingsRow(
                context,
                icon: Icons.privacy_tip_outlined,
                iconColor: AppColors.iconPurple,
                label: l10n.profilePrivacyOptionsLabel,
                onTap: onPrivacyOptions,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _buildSectionLabel(context, l10n.profileSectionCalendar),
        const SizedBox(height: 8),
        _buildGroupCard(
          context,
          children: [
            _buildSettingsRow(
              context,
              icon: Icons.calendar_month_outlined,
              iconColor: AppColors.iconOrange,
              label: l10n.profileCalendarSyncLabel,
              value: calendarSyncEnabled
                  ? l10n.profileCalendarSyncOn
                  : l10n.profileCalendarSyncOff,
              onTap: onCalendarSyncTap,
              busy: calendarSyncBusy,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionLabel(context, l10n.profileSectionData),
        const SizedBox(height: 8),
        _buildGroupCard(
          context,
          children: [
            _buildSettingsRow(
              context,
              icon: Icons.timer_off_outlined,
              iconColor: AppColors.overdue,
              label: l10n.profileDeleteSessionsLabel,
              labelColor: AppColors.overdue,
              onTap: onDeleteSessions,
              showChevron: false,
            ),
            _buildDivider(context),
            _buildSettingsRow(
              context,
              icon: Icons.delete_outline,
              iconColor: AppColors.overdue,
              label: l10n.profileDeleteEverythingLabel,
              labelColor: AppColors.overdue,
              onTap: onDeleteEverything,
              showChevron: false,
            ),
          ],
        ),
      ],
    );
  }

  /// Gold pill marking the user as a subscriber. Shown under the school name.
  /// Tapping it opens Apple's subscription settings — with the upgrade card
  /// hidden for subscribers, this is their route to manage the plan.
  Widget _buildPremiumPill(BuildContext context) {
    return GestureDetector(
      onTap: onSubscriptionTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.premiumGold, AppColors.premiumGoldLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.premiumGold.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.diamond,
              size: 12,
              color: AppColors.premiumGoldText,
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.profilePremiumBadge.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppColors.premiumGoldText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
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
                colors: [AppColors.primary, AppColors.primaryLight],
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
                        ? context.colors.textTertiary
                        : context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onEditName,
                  child: Text(
                    schoolName.isEmpty ? context.l10n.profileSchoolNamePlaceholder : schoolName,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ),
                if (isPremium) ...[
                  const SizedBox(height: 8),
                  _buildPremiumPill(context),
                ],
              ],
            ),
          ),
          // Edit button
          IconButton(
            onPressed: onEditName,
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.border,
          ),
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    String? value,
    Color? labelColor,
    required VoidCallback onTap,
    bool showChevron = true,
    bool busy = false,
  }) {
    return InkWell(
      // Ignored while busy so the row cannot be re-entered mid-operation.
      onTap: busy ? null : onTap,
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
                  color: labelColor ?? context.colors.textPrimary,
                ),
              ),
            ),
            // Value + chevron, or a spinner while the row is working
            if (busy)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.textTertiary,
                ),
              )
            else ...[
              if (value != null) ...[
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              if (showChevron)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: context.colors.textTertiary,
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Upgrade card, only built for non-subscribers — subscribers see the
  /// Premium pill in the header instead.
  Widget _buildPremiumCard(BuildContext context) {
    final isDark = context.colors.isDark;

    // Non-premium: gradient card met Upgrade knop
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onSubscriptionTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF1E2A4A), Color(0xFF1A1F3A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.10)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            children: [
              // Icon
              const PremiumIcon(size: 60),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profileUpgradeTitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: isDark
                            ? const Color(0xFFBFD7FF)
                            : const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.l10n.profileUpgradeSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: isDark
                            ? const Color(0xFFDDE9FF)
                            : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Upgrade button (tap handled by outer GestureDetector)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  context.l10n.profileUpgradeButton,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 66),
      child: Divider(
        height: 1,
        color: context.colors.divider,
      ),
    );
  }
}
