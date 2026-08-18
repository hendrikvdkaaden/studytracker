// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navDeadlines => 'Deadlines';

  @override
  String get navProfile => 'Profile';

  @override
  String get btnSave => 'Save';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnEdit => 'Edit';

  @override
  String get btnAdd => 'Add';

  @override
  String get btnDone => 'Done';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get btnClose => 'Close';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonNoData => 'No data available';

  @override
  String get addGoalTitle => 'Add Deadline';

  @override
  String get editGoalTitle => 'Edit Deadline';

  @override
  String get addGoalSubjectLabel => 'Subject';

  @override
  String get addGoalSubjectHint => 'e.g. Mathematics';

  @override
  String get addGoalTitleLabel => 'Title';

  @override
  String get addGoalTitleHint => 'e.g. Chapter 5 Exam';

  @override
  String get addGoalDeadlineLabel => 'Deadline';

  @override
  String get addGoalDeadlineTimeLabel => 'Time';

  @override
  String get addGoalTypeLabel => 'Deadline Type';

  @override
  String get addGoalDifficultyLabel => 'Difficulty';

  @override
  String get addGoalStudyTimeLabel => 'Target Study Time';

  @override
  String get addGoalStudyTimePlaceholder => 'Set study time';

  @override
  String get addGoalSessionsLabel => 'Planned Sessions';

  @override
  String get addGoalSaveButton => 'Save Deadline';

  @override
  String get addGoalValidateSubject => 'Please enter a subject';

  @override
  String get addGoalValidateTitle => 'Please enter a title';

  @override
  String get addGoalValidateDeadline => 'Please select a deadline';

  @override
  String get addGoalValidateType => 'Please select a deadline type';

  @override
  String get addGoalValidateDifficulty => 'Please select a difficulty';

  @override
  String get addGoalValidateStudyTime => 'Please set a target study time';

  @override
  String addGoalSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
      zero: 'No sessions',
    );
    return '$_temp0';
  }

  @override
  String get addGoalAutoPlanButton => 'Plan for me';

  @override
  String get addGoalAddSessionButton => 'Add study session';

  @override
  String get addGoalAddSessionShort => 'Add session';

  @override
  String get addGoalSaveButtonLabel => 'Add Deadline';

  @override
  String get sessionPickerTitleAdd => 'Plan Study Session';

  @override
  String get sessionPickerTitleEdit => 'Edit Session';

  @override
  String get sessionPickerDateLabel => 'Date';

  @override
  String get sessionPickerStartTimeLabel => 'Start Time';

  @override
  String get sessionPickerDurationLabel => 'Duration';

  @override
  String get sessionPickerNotesLabel => 'Notes (Optional)';

  @override
  String get sessionPickerNotesHint => 'What will you study?';

  @override
  String get sessionPickerSaveButton => 'Add Session';

  @override
  String get sessionPickerSaveEditButton => 'Save Changes';

  @override
  String get sessionPickerOverlapError =>
      'This session overlaps with an existing session.';

  @override
  String get sessionPickerDurationError =>
      'Set a duration longer than 0 minutes.';

  @override
  String get sessionPickerHours => 'Hours';

  @override
  String get sessionPickerMinutes => 'Minutes';

  @override
  String get autoPlanTitle => 'Session Planner';

  @override
  String get autoPlanTotalStudyTimeLabel => 'Total Study Time';

  @override
  String get autoPlanStudyDaysLabel => 'Study Days';

  @override
  String get autoPlanStudyWindowLabel => 'Study Window';

  @override
  String get autoPlanSessionDurationLabel => 'Session Duration';

  @override
  String get autoPlanBreakDurationLabel => 'Break Between Sessions';

  @override
  String get autoPlanBreakNone => 'None';

  @override
  String get autoPlanBreak15 => '15 min';

  @override
  String get autoPlanBreak30 => '30 min';

  @override
  String get autoPlanBreak45 => '45 min';

  @override
  String get autoPlanBreak60 => '1 hour';

  @override
  String get autoPlanConfirmButton => 'Plan Sessions';

  @override
  String get autoPlanErrorNoDays => 'Select at least one study day.';

  @override
  String get autoPlanErrorNoTime => 'Set a total study time.';

  @override
  String get autoPlanErrorNoSessionDuration => 'Set a session duration.';

  @override
  String get autoPlanErrorWindowNegative =>
      'End time must be after start time.';

  @override
  String get autoPlanErrorSessionTooLong =>
      'Session duration does not fit within the study window.';

  @override
  String get timerDialogLeaveTitle => 'Exit Timer?';

  @override
  String get timerDialogLeaveBody =>
      'Your progress will be saved. You can continue later.';

  @override
  String get timerDialogLeaveConfirm => 'Exit';

  @override
  String get timerDialogLeaveCancel => 'Cancel';

  @override
  String get timerDialogCompleteTitle => 'Complete Session?';

  @override
  String timerDialogCompleteBody(String time) {
    return 'You studied for $time. Save this session?';
  }

  @override
  String get timerDialogCompleteConfirm => 'Save';

  @override
  String get timerDialogCompleteCancel => 'Cancel';

  @override
  String get timerDialogMarkCompleteTitle => 'Mark as Complete?';

  @override
  String get timerDialogMarkCompleteBody =>
      'Mark this session as fully completed? The full session duration will be logged.';

  @override
  String get timerDialogMarkCompleteConfirm => 'Complete';

  @override
  String timerSnackSessionSaved(String time) {
    return 'Session saved! $time logged.';
  }

  @override
  String get timerSnackSessionCompleted => 'Session completed!';

  @override
  String get goalDetailsSectionInfo => 'Deadline Info';

  @override
  String get goalDetailsSectionStudySessions => 'Study Sessions';

  @override
  String get goalDetailsSectionProgress => 'Progress';

  @override
  String get goalDetailsNoSessions => 'No sessions planned yet';

  @override
  String get goalDetailsAddSession => 'Add study session';

  @override
  String get goalDetailsAddSessionShort => 'Add session';

  @override
  String get goalDetailsMarkComplete => 'Mark as Completed';

  @override
  String get goalDetailsMarkIncomplete => 'Mark as Incomplete';

  @override
  String get goalDetailsDeleteGoal => 'Delete Deadline';

  @override
  String get goalDetailsDeleteConfirmTitle => 'Delete Deadline';

  @override
  String get goalDetailsDeleteConfirmBody =>
      'Are you sure you want to delete this deadline?';

  @override
  String get goalDetailsProgressLabel => 'Progress';

  @override
  String get goalDetailsEditProgressTitle => 'Edit Progress';

  @override
  String get goalDetailsTargetTimeLabel => 'Target Time';

  @override
  String get goalDetailsTimeSpentLabel => 'Time Spent';

  @override
  String get goalDetailsHideCompleted => 'Hide completed';

  @override
  String get goalDetailsShowCompleted => 'Show completed';

  @override
  String get goalDetailsAllSessionsCompleted => 'All sessions are completed';

  @override
  String get goalDetailsShowCompletedHint =>
      'Tap \"Show completed\" above to view them';

  @override
  String goalDetailsSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
      zero: 'No sessions',
    );
    return '$_temp0';
  }

  @override
  String get goalInfoCardLabel => 'DEADLINE INFO';

  @override
  String get goalInfoDeadlineLabel => 'DEADLINE';

  @override
  String get goalInfoProgressLabel => 'PROGRESS';

  @override
  String get goalInfoSessionsLabel => 'STUDY SESSIONS';

  @override
  String get goalInfoEditModalTitle => 'Edit Deadline Info';

  @override
  String get goalInfoEditTitleLabel => 'Title';

  @override
  String get goalInfoEditTitleHint => 'Deadline title';

  @override
  String get goalInfoEditTypeLabel => 'Deadline Type';

  @override
  String get goalInfoEditDifficultyLabel => 'Difficulty';

  @override
  String get goalInfoEditSaveButton => 'Save Changes';

  @override
  String get goalInfoEditValidateTitle => 'Please enter a title';

  @override
  String get goalInfoEditValidateSubject => 'Please select a subject';

  @override
  String deadlineStatusDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String deadlineStatusDaysOverdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String get deadlineStatusToday => 'Today';

  @override
  String get deadlineStatusTomorrow => 'Tomorrow';

  @override
  String get deadlineStatusCompleted => 'Completed';

  @override
  String get dashboardTitle => 'Deadlines';

  @override
  String get dashboardSectionOverdue => 'Overdue';

  @override
  String get dashboardSectionUpcoming => 'Upcoming';

  @override
  String get dashboardSectionCompleted => 'Completed';

  @override
  String get dashboardEmptyTitle => 'No deadlines yet';

  @override
  String get dashboardEmptySubtitle => 'Tap + to create your first deadline';

  @override
  String get dashboardSeeAll => 'SEE ALL';

  @override
  String get consistencyTitle => 'STUDY CONSISTENCY';

  @override
  String get consistencyNoSessionsTitle => 'Start Your Week Strong';

  @override
  String get consistencyNoSessionsSubtitle =>
      'Plan some study sessions to track your week.';

  @override
  String consistencyMissedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sessions Missed',
      one: '1 Session Missed',
    );
    return '$_temp0';
  }

  @override
  String get consistencyMissedSubtitle =>
      'Don\'t give up! You can still crush this week.';

  @override
  String consistencyDaysNoMissed(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Completed all Sessions for $days Days',
      one: 'Completed all Sessions Today',
    );
    return '$_temp0';
  }

  @override
  String get consistencyDaysNoMissedSubtitle =>
      'Great job! Keep up the consistency.';

  @override
  String get profileSectionSubjects => 'SUBJECTS';

  @override
  String get profileSectionNotifications => 'NOTIFICATIONS';

  @override
  String get profileSectionAppearance => 'APPEARANCE';

  @override
  String get profileSectionData => 'DATA';

  @override
  String get profileSectionPrivacy => 'PRIVACY';

  @override
  String get profilePrivacyOptionsLabel => 'Ad privacy settings';

  @override
  String get profileNamePlaceholder => 'Add your name';

  @override
  String get profileSchoolNamePlaceholder => 'Tap to set school name';

  @override
  String get profileSessionReminderLabel => 'Session reminder';

  @override
  String get profileDeadlineReminderLabel => 'Deadline reminder';

  @override
  String get profileThemeLabel => 'Theme';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileDeleteSessionsLabel => 'Delete all study sessions';

  @override
  String get profileDeleteEverythingLabel => 'Delete everything';

  @override
  String profileVersionLabel(String version) {
    return 'Deadly $version';
  }

  @override
  String profileSessionReminderFormat(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes before',
      one: '1 minute before',
      zero: 'Disabled',
    );
    return '$_temp0';
  }

  @override
  String profileDeadlineReminderFormat(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get profilePickerSessionTitle => 'Session reminder';

  @override
  String get profilePickerSessionSubtitle =>
      'How long before a session should we remind you?';

  @override
  String get profilePickerDeadlineTitle => 'Deadline reminder';

  @override
  String get profilePickerDeadlineSubtitle =>
      'How many days before a deadline should we remind you?';

  @override
  String get profilePickerThemeTitle => 'Appearance';

  @override
  String profilePickerSessionOptionFormat(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
    );
    return '$_temp0';
  }

  @override
  String profilePickerDeadlineOptionFormat(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get profileDeleteSessionsTitle => 'Delete all study sessions?';

  @override
  String get profileDeleteSessionsBody =>
      'This will permanently delete all your study sessions. Your deadlines will remain intact.';

  @override
  String get profileDeleteSessionsConfirm => 'Delete sessions';

  @override
  String get profileDeleteEverythingTitle => 'Delete everything?';

  @override
  String get profileDeleteEverythingBody =>
      'This will permanently delete all your deadlines and study sessions. This action cannot be undone.';

  @override
  String get profileDeleteEverythingConfirm => 'Delete everything';

  @override
  String get profileDeleteSessionsSnack => 'All study sessions deleted.';

  @override
  String get profileDeleteEverythingSnack => 'All data deleted.';

  @override
  String get profileRemoveSubjectTitle => 'Remove subject?';

  @override
  String profileRemoveSubjectBody(String name) {
    return '\"$name\" will be removed from your subjects list. Deadlines using this subject are not affected.';
  }

  @override
  String get profileRemoveSubjectConfirm => 'Remove';

  @override
  String get addSubjectTitle => 'Add Subject';

  @override
  String get addSubjectSubtitle => 'Choose a name and color';

  @override
  String get addSubjectNameLabel => 'SUBJECT NAME';

  @override
  String get addSubjectColorLabel => 'THEME COLOR';

  @override
  String get addSubjectHint => 'e.g. Physics';

  @override
  String get addSubjectSaveButton => 'Create';

  @override
  String get addSubjectErrorEmpty => 'Please enter a subject name';

  @override
  String get editNameTitle => 'Edit Name';

  @override
  String get editNameSubtitle =>
      'This is how you\'ll appear to your study group.';

  @override
  String get editNameDisplayLabel => 'DISPLAY NAME';

  @override
  String get editNameSchoolLabel => 'SCHOOL NAME';

  @override
  String get editNameDisplayHint => 'Enter your name';

  @override
  String get editNameSchoolHint => 'Enter school name';

  @override
  String get editNameSaveButton => 'Update';

  @override
  String get goalDialogDeleteTitle => 'Delete Deadline';

  @override
  String get goalDialogDeleteBody =>
      'Are you sure you want to delete this deadline?';

  @override
  String get homeNoTasksTitle => 'No tasks for this day';

  @override
  String get homeNoTasksSubtitle => 'Select another day or add a new deadline';

  @override
  String get homeDeadlinesToday => 'Deadlines Today';

  @override
  String get homeStudySessions => 'Study Sessions';

  @override
  String get calendarSectionGoals => 'Deadlines';

  @override
  String get calendarSectionSessions => 'Sessions';

  @override
  String get calendarNoGoals => 'No deadlines on this day';

  @override
  String get calendarNoSessions => 'No sessions on this day';

  @override
  String get calendarTodayButton => 'Today';

  @override
  String get goalTypeExam => 'Exam';

  @override
  String get goalTypeTest => 'Test';

  @override
  String get goalTypeAssignment => 'Assignment';

  @override
  String get goalTypePresentation => 'Presentation';

  @override
  String get goalTypeProject => 'Project';

  @override
  String get goalTypePaper => 'Paper';

  @override
  String get goalTypeQuiz => 'Quiz';

  @override
  String get goalTypeOther => 'Other';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyVeryHard => 'Very Hard';

  @override
  String plannedSessionDuration(int duration) {
    return '$duration min';
  }

  @override
  String get plannedSessionNoTime => 'No time set';

  @override
  String get progressEditTargetTime => 'Target Time';

  @override
  String get progressEditTimeSpent => 'Time Spent';

  @override
  String get progressEditHours => 'HOURS';

  @override
  String get progressEditMinutes => 'MINUTES';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingLetsGo => 'Let\'s go!';

  @override
  String get onboardingLandingTagline => 'Stay on top of your deadlines';

  @override
  String onboardingStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingStep1Title => 'What\'s your name?';

  @override
  String get onboardingStep1Subtitle =>
      'We\'ll use this to personalize your experience';

  @override
  String get onboardingNameHint => 'Your name...';

  @override
  String get onboardingNameError => 'Please enter your name';

  @override
  String get onboardingSchoolHint => 'School or university (optional)';

  @override
  String get onboardingStep2Title => 'Add your subjects';

  @override
  String get onboardingStep2Subtitle =>
      'Add the subjects you\'re studying so you can organize your deadlines';

  @override
  String get onboardingStep2Note =>
      'You can always add more subjects later in your profile.';

  @override
  String get onboardingAddSubject => 'Add a subject';

  @override
  String get onboardingStep3Title => 'Set up reminders';

  @override
  String get onboardingStep3Subtitle =>
      'Get notified before your study sessions and deadlines';

  @override
  String get onboardingStep3Note =>
      'You can change this later in your Profile.';

  @override
  String get onboardingSessionReminder => 'Session reminder';

  @override
  String get onboardingDeadlineReminder => 'Deadline reminder';

  @override
  String get paywallTitle => 'Unlock Deadly Premium';

  @override
  String get paywallSubtitle => 'Accelerate your learning with smart planning';

  @override
  String get paywallFeature1 => 'Unlimited deadlines & subjects';

  @override
  String get paywallFeature2 => 'Smart auto-planning for your study sessions';

  @override
  String get paywallFeature3 =>
      'Distributes sessions evenly before your deadline';

  @override
  String get paywallYearlyLabel => 'Yearly';

  @override
  String paywallYearlySubtitle(String pricePerMonth) {
    return '$pricePerMonth / month, billed annually';
  }

  @override
  String get paywallYearlySubtitleFallback => 'Billed annually';

  @override
  String paywallYearlySaveBadge(int percent) {
    return 'SAVE $percent%';
  }

  @override
  String get paywallYearlyValueBadge => 'BEST VALUE';

  @override
  String get paywallMonthlyLabel => 'Monthly';

  @override
  String get paywallMonthlySubtitle => 'Cancel anytime';

  @override
  String get paywallPeriodMonth => 'per month';

  @override
  String get paywallPeriodYear => 'per year';

  @override
  String get paywallNoOfferings =>
      'No offerings available. Please check back later.';

  @override
  String get paywallCtaButton => 'UPGRADE TO PREMIUM';

  @override
  String get paywallRestorePurchases => 'Restore Purchases';

  @override
  String get paywallDisclaimerText =>
      'Auto-renews until cancelled. Manage in your Apple ID settings.';

  @override
  String get paywallTermsOfUse => 'Terms of Use';

  @override
  String get paywallPrivacyPolicy => 'Privacy Policy';

  @override
  String get paywallLegalSeparator => ' · ';

  @override
  String get paywallErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get paywallErrorNoPurchases => 'No previous purchases found.';

  @override
  String get paywallErrorRestoreFailed => 'Restore failed. Please try again.';

  @override
  String get profilePremiumBadge => 'Premium';

  @override
  String get profilePremiumTitle => 'Deadly Premium';

  @override
  String get profileUpgradeTitle => 'DEADLY PREMIUM';

  @override
  String get profilePremiumSubtitle => 'Manage your subscription';

  @override
  String get profileUpgradeSubtitle => 'Unlock all features';

  @override
  String get profileUpgradeButton => 'Upgrade';

  @override
  String get profileManageSubscription =>
      'Manage your subscription via the App Store settings.';

  @override
  String get autoPlanErrorNoAvailableDays =>
      'No available days found before the deadline.';

  @override
  String autoPlanSuccessSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions planned!',
      one: '1 session planned!',
    );
    return '$_temp0';
  }

  @override
  String addGoalSuccessSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deadline and $count sessions added!',
      one: 'Deadline and 1 session added!',
      zero: 'Deadline added successfully!',
    );
    return '$_temp0';
  }

  @override
  String get addGoalScreenTitle => 'Create Deadline';

  @override
  String get premiumAutoPlanTitle => 'Premium Feature';

  @override
  String get premiumAutoPlanMessage =>
      'Auto-planning is a Deadly Premium feature. Upgrade to automatically schedule your study sessions.';

  @override
  String get premiumGoalLimitTitle => 'Deadline Limit Reached';

  @override
  String get premiumGoalLimitMessage =>
      'You\'ve reached the free limit of 3 deadlines. Upgrade to Deadly Premium to create unlimited deadlines.';

  @override
  String get premiumDialogUpgradeButton => 'Upgrade to Premium';

  @override
  String get premiumDialogNotNow => 'Not Now';

  @override
  String get premiumDialogWatchAd => 'Watch an ad to try once';
}
