import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navDeadlines.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navDeadlines;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @btnEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btnEdit;

  /// No description provided for @btnAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btnAdd;

  /// No description provided for @btnDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get btnDone;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// No description provided for @btnClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get commonNoData;

  /// No description provided for @addGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoalTitle;

  /// No description provided for @editGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoalTitle;

  /// No description provided for @addGoalSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get addGoalSubjectLabel;

  /// No description provided for @addGoalSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mathematics'**
  String get addGoalSubjectHint;

  /// No description provided for @addGoalTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get addGoalTitleLabel;

  /// No description provided for @addGoalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chapter 5 Exam'**
  String get addGoalTitleHint;

  /// No description provided for @addGoalDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get addGoalDeadlineLabel;

  /// No description provided for @addGoalTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal Type'**
  String get addGoalTypeLabel;

  /// No description provided for @addGoalDifficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get addGoalDifficultyLabel;

  /// No description provided for @addGoalStudyTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Study Time'**
  String get addGoalStudyTimeLabel;

  /// No description provided for @addGoalStudyTimePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Set study time'**
  String get addGoalStudyTimePlaceholder;

  /// No description provided for @addGoalSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Planned Sessions'**
  String get addGoalSessionsLabel;

  /// No description provided for @addGoalSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Goal'**
  String get addGoalSaveButton;

  /// No description provided for @addGoalValidateSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get addGoalValidateSubject;

  /// No description provided for @addGoalValidateTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get addGoalValidateTitle;

  /// No description provided for @addGoalValidateDeadline.
  ///
  /// In en, this message translates to:
  /// **'Please select a deadline'**
  String get addGoalValidateDeadline;

  /// No description provided for @addGoalValidateType.
  ///
  /// In en, this message translates to:
  /// **'Please select a goal type'**
  String get addGoalValidateType;

  /// No description provided for @addGoalValidateDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Please select a difficulty'**
  String get addGoalValidateDifficulty;

  /// No description provided for @addGoalValidateStudyTime.
  ///
  /// In en, this message translates to:
  /// **'Please set a target study time'**
  String get addGoalValidateStudyTime;

  /// No description provided for @addGoalSessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sessions} =1{1 session} other{{count} sessions}}'**
  String addGoalSessionCount(int count);

  /// No description provided for @addGoalAutoPlanButton.
  ///
  /// In en, this message translates to:
  /// **'Plan for me'**
  String get addGoalAutoPlanButton;

  /// No description provided for @addGoalAddSessionButton.
  ///
  /// In en, this message translates to:
  /// **'Add study session'**
  String get addGoalAddSessionButton;

  /// No description provided for @addGoalAddSessionShort.
  ///
  /// In en, this message translates to:
  /// **'Add session'**
  String get addGoalAddSessionShort;

  /// No description provided for @addGoalSaveButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Deadline'**
  String get addGoalSaveButtonLabel;

  /// No description provided for @sessionPickerTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Plan Study Session'**
  String get sessionPickerTitleAdd;

  /// No description provided for @sessionPickerTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Session'**
  String get sessionPickerTitleEdit;

  /// No description provided for @sessionPickerDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sessionPickerDateLabel;

  /// No description provided for @sessionPickerStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get sessionPickerStartTimeLabel;

  /// No description provided for @sessionPickerDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sessionPickerDurationLabel;

  /// No description provided for @sessionPickerNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get sessionPickerNotesLabel;

  /// No description provided for @sessionPickerNotesHint.
  ///
  /// In en, this message translates to:
  /// **'What will you study?'**
  String get sessionPickerNotesHint;

  /// No description provided for @sessionPickerSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Add Session'**
  String get sessionPickerSaveButton;

  /// No description provided for @sessionPickerSaveEditButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get sessionPickerSaveEditButton;

  /// No description provided for @sessionPickerOverlapError.
  ///
  /// In en, this message translates to:
  /// **'This session overlaps with an existing session.'**
  String get sessionPickerOverlapError;

  /// No description provided for @sessionPickerHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get sessionPickerHours;

  /// No description provided for @sessionPickerMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get sessionPickerMinutes;

  /// No description provided for @autoPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Sessions'**
  String get autoPlanTitle;

  /// No description provided for @autoPlanTotalStudyTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Study Time'**
  String get autoPlanTotalStudyTimeLabel;

  /// No description provided for @autoPlanStudyDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Study Days'**
  String get autoPlanStudyDaysLabel;

  /// No description provided for @autoPlanStudyWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Study Window'**
  String get autoPlanStudyWindowLabel;

  /// No description provided for @autoPlanSessionDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Session Duration'**
  String get autoPlanSessionDurationLabel;

  /// No description provided for @autoPlanConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Plan Sessions'**
  String get autoPlanConfirmButton;

  /// No description provided for @autoPlanErrorNoDays.
  ///
  /// In en, this message translates to:
  /// **'Select at least one study day.'**
  String get autoPlanErrorNoDays;

  /// No description provided for @autoPlanErrorNoTime.
  ///
  /// In en, this message translates to:
  /// **'Set a total study time.'**
  String get autoPlanErrorNoTime;

  /// No description provided for @autoPlanErrorNoSessionDuration.
  ///
  /// In en, this message translates to:
  /// **'Set a session duration.'**
  String get autoPlanErrorNoSessionDuration;

  /// No description provided for @autoPlanErrorWindowNegative.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get autoPlanErrorWindowNegative;

  /// No description provided for @autoPlanErrorSessionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Session duration does not fit within the study window.'**
  String get autoPlanErrorSessionTooLong;

  /// No description provided for @timerDialogLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Timer?'**
  String get timerDialogLeaveTitle;

  /// No description provided for @timerDialogLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be saved. You can continue later.'**
  String get timerDialogLeaveBody;

  /// No description provided for @timerDialogLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get timerDialogLeaveConfirm;

  /// No description provided for @timerDialogLeaveCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get timerDialogLeaveCancel;

  /// No description provided for @timerDialogCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Session?'**
  String get timerDialogCompleteTitle;

  /// No description provided for @timerDialogCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You studied for {time}. Save this session?'**
  String timerDialogCompleteBody(String time);

  /// No description provided for @timerDialogCompleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get timerDialogCompleteConfirm;

  /// No description provided for @timerDialogCompleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get timerDialogCompleteCancel;

  /// No description provided for @timerDialogMarkCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete?'**
  String get timerDialogMarkCompleteTitle;

  /// No description provided for @timerDialogMarkCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Mark this session as fully completed? The full session duration will be logged.'**
  String get timerDialogMarkCompleteBody;

  /// No description provided for @timerDialogMarkCompleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get timerDialogMarkCompleteConfirm;

  /// No description provided for @timerSnackSessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Session saved! {time} logged.'**
  String timerSnackSessionSaved(String time);

  /// No description provided for @timerSnackSessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Session completed!'**
  String get timerSnackSessionCompleted;

  /// No description provided for @goalDetailsSectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Goal Info'**
  String get goalDetailsSectionInfo;

  /// No description provided for @goalDetailsSectionStudySessions.
  ///
  /// In en, this message translates to:
  /// **'Study Sessions'**
  String get goalDetailsSectionStudySessions;

  /// No description provided for @goalDetailsSectionProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get goalDetailsSectionProgress;

  /// No description provided for @goalDetailsNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions planned yet'**
  String get goalDetailsNoSessions;

  /// No description provided for @goalDetailsAddSession.
  ///
  /// In en, this message translates to:
  /// **'Add study session'**
  String get goalDetailsAddSession;

  /// No description provided for @goalDetailsAddSessionShort.
  ///
  /// In en, this message translates to:
  /// **'Add session'**
  String get goalDetailsAddSessionShort;

  /// No description provided for @goalDetailsMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get goalDetailsMarkComplete;

  /// No description provided for @goalDetailsMarkIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Incomplete'**
  String get goalDetailsMarkIncomplete;

  /// No description provided for @goalDetailsDeleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get goalDetailsDeleteGoal;

  /// No description provided for @goalDetailsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get goalDetailsDeleteConfirmTitle;

  /// No description provided for @goalDetailsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this goal?'**
  String get goalDetailsDeleteConfirmBody;

  /// No description provided for @goalDetailsProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get goalDetailsProgressLabel;

  /// No description provided for @goalDetailsEditProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Progress'**
  String get goalDetailsEditProgressTitle;

  /// No description provided for @goalDetailsTargetTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Time'**
  String get goalDetailsTargetTimeLabel;

  /// No description provided for @goalDetailsTimeSpentLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Spent'**
  String get goalDetailsTimeSpentLabel;

  /// No description provided for @goalDetailsHideCompleted.
  ///
  /// In en, this message translates to:
  /// **'Hide completed'**
  String get goalDetailsHideCompleted;

  /// No description provided for @goalDetailsShowCompleted.
  ///
  /// In en, this message translates to:
  /// **'Show completed'**
  String get goalDetailsShowCompleted;

  /// No description provided for @goalDetailsAllSessionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'All sessions are completed'**
  String get goalDetailsAllSessionsCompleted;

  /// No description provided for @goalDetailsShowCompletedHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Show completed\" above to view them'**
  String get goalDetailsShowCompletedHint;

  /// No description provided for @goalDetailsSessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sessions} =1{1 session} other{{count} sessions}}'**
  String goalDetailsSessionCount(int count);

  /// No description provided for @goalInfoCardLabel.
  ///
  /// In en, this message translates to:
  /// **'GOAL INFO'**
  String get goalInfoCardLabel;

  /// No description provided for @goalInfoDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'DEADLINE'**
  String get goalInfoDeadlineLabel;

  /// No description provided for @goalInfoProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get goalInfoProgressLabel;

  /// No description provided for @goalInfoSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'STUDY SESSIONS'**
  String get goalInfoSessionsLabel;

  /// No description provided for @goalInfoEditModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Deadline Info'**
  String get goalInfoEditModalTitle;

  /// No description provided for @goalInfoEditTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get goalInfoEditTitleLabel;

  /// No description provided for @goalInfoEditTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Deadline title'**
  String get goalInfoEditTitleHint;

  /// No description provided for @goalInfoEditTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline Type'**
  String get goalInfoEditTypeLabel;

  /// No description provided for @goalInfoEditDifficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get goalInfoEditDifficultyLabel;

  /// No description provided for @goalInfoEditSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get goalInfoEditSaveButton;

  /// No description provided for @goalInfoEditValidateTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get goalInfoEditValidateTitle;

  /// No description provided for @goalInfoEditValidateSubject.
  ///
  /// In en, this message translates to:
  /// **'Please select a subject'**
  String get goalInfoEditValidateSubject;

  /// No description provided for @deadlineStatusDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day left} other{{days} days left}}'**
  String deadlineStatusDaysLeft(int days);

  /// No description provided for @deadlineStatusDaysOverdue.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day overdue} other{{days} days overdue}}'**
  String deadlineStatusDaysOverdue(int days);

  /// No description provided for @deadlineStatusToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get deadlineStatusToday;

  /// No description provided for @deadlineStatusTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get deadlineStatusTomorrow;

  /// No description provided for @deadlineStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get deadlineStatusCompleted;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get dashboardTitle;

  /// No description provided for @dashboardSectionOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get dashboardSectionOverdue;

  /// No description provided for @dashboardSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get dashboardSectionUpcoming;

  /// No description provided for @dashboardSectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dashboardSectionCompleted;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No deadlines yet'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first deadline'**
  String get dashboardEmptySubtitle;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'SEE ALL'**
  String get dashboardSeeAll;

  /// No description provided for @consistencyTitle.
  ///
  /// In en, this message translates to:
  /// **'STUDY CONSISTENCY'**
  String get consistencyTitle;

  /// No description provided for @consistencyNoSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Your Week Strong'**
  String get consistencyNoSessionsTitle;

  /// No description provided for @consistencyNoSessionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan some study sessions to track your week.'**
  String get consistencyNoSessionsSubtitle;

  /// No description provided for @consistencyMissedTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Session Missed} other{{count} Sessions Missed}}'**
  String consistencyMissedTitle(int count);

  /// No description provided for @consistencyMissedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t give up! You can still crush this week.'**
  String get consistencyMissedSubtitle;

  /// No description provided for @consistencyDaysNoMissed.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 Day No Session Missed} other{{days} Days No Session Missed}}'**
  String consistencyDaysNoMissed(int days);

  /// No description provided for @consistencyDaysNoMissedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Great job! Keep up the consistency.'**
  String get consistencyDaysNoMissedSubtitle;

  /// No description provided for @profileSectionSubjects.
  ///
  /// In en, this message translates to:
  /// **'SUBJECTS'**
  String get profileSectionSubjects;

  /// No description provided for @profileSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get profileSectionNotifications;

  /// No description provided for @profileSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get profileSectionAppearance;

  /// No description provided for @profileSectionData.
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get profileSectionData;

  /// No description provided for @profileNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add your name'**
  String get profileNamePlaceholder;

  /// No description provided for @profileSchoolNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap to set school name'**
  String get profileSchoolNamePlaceholder;

  /// No description provided for @profileSessionReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Session reminder'**
  String get profileSessionReminderLabel;

  /// No description provided for @profileDeadlineReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Deadline reminder'**
  String get profileDeadlineReminderLabel;

  /// No description provided for @profileThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileThemeLabel;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileDeleteSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete all study sessions'**
  String get profileDeleteSessionsLabel;

  /// No description provided for @profileDeleteEverythingLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get profileDeleteEverythingLabel;

  /// No description provided for @profileVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'StudyTracker {version}'**
  String profileVersionLabel(String version);

  /// No description provided for @profileSessionReminderFormat.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =0{Disabled} =1{1 minute before} other{{minutes} minutes before}}'**
  String profileSessionReminderFormat(int minutes);

  /// No description provided for @profileDeadlineReminderFormat.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day before} other{{days} days before}}'**
  String profileDeadlineReminderFormat(int days);

  /// No description provided for @profilePickerSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session reminder'**
  String get profilePickerSessionTitle;

  /// No description provided for @profilePickerSessionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How long before a session should we remind you?'**
  String get profilePickerSessionSubtitle;

  /// No description provided for @profilePickerDeadlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Deadline reminder'**
  String get profilePickerDeadlineTitle;

  /// No description provided for @profilePickerDeadlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How many days before a deadline should we remind you?'**
  String get profilePickerDeadlineSubtitle;

  /// No description provided for @profilePickerThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profilePickerThemeTitle;

  /// No description provided for @profilePickerSessionOptionFormat.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, other{{minutes} minutes before}}'**
  String profilePickerSessionOptionFormat(int minutes);

  /// No description provided for @profilePickerDeadlineOptionFormat.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day before} other{{days} days before}}'**
  String profilePickerDeadlineOptionFormat(int days);

  /// No description provided for @profileDeleteSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all study sessions?'**
  String get profileDeleteSessionsTitle;

  /// No description provided for @profileDeleteSessionsBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your study sessions. Your deadlines will remain intact.'**
  String get profileDeleteSessionsBody;

  /// No description provided for @profileDeleteSessionsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete sessions'**
  String get profileDeleteSessionsConfirm;

  /// No description provided for @profileDeleteEverythingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get profileDeleteEverythingTitle;

  /// No description provided for @profileDeleteEverythingBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your deadlines and study sessions. This action cannot be undone.'**
  String get profileDeleteEverythingBody;

  /// No description provided for @profileDeleteEverythingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get profileDeleteEverythingConfirm;

  /// No description provided for @profileDeleteSessionsSnack.
  ///
  /// In en, this message translates to:
  /// **'All study sessions deleted.'**
  String get profileDeleteSessionsSnack;

  /// No description provided for @profileDeleteEverythingSnack.
  ///
  /// In en, this message translates to:
  /// **'All data deleted.'**
  String get profileDeleteEverythingSnack;

  /// No description provided for @profileRemoveSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove subject?'**
  String get profileRemoveSubjectTitle;

  /// No description provided for @profileRemoveSubjectBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed from your subjects list. Deadlines using this subject are not affected.'**
  String profileRemoveSubjectBody(String name);

  /// No description provided for @profileRemoveSubjectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get profileRemoveSubjectConfirm;

  /// No description provided for @addSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Subject'**
  String get addSubjectTitle;

  /// No description provided for @addSubjectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a name and color'**
  String get addSubjectSubtitle;

  /// No description provided for @addSubjectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'SUBJECT NAME'**
  String get addSubjectNameLabel;

  /// No description provided for @addSubjectColorLabel.
  ///
  /// In en, this message translates to:
  /// **'THEME COLOR'**
  String get addSubjectColorLabel;

  /// No description provided for @addSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Physics'**
  String get addSubjectHint;

  /// No description provided for @addSubjectSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get addSubjectSaveButton;

  /// No description provided for @addSubjectErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject name'**
  String get addSubjectErrorEmpty;

  /// No description provided for @editNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editNameTitle;

  /// No description provided for @editNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is how you\'ll appear to your study group.'**
  String get editNameSubtitle;

  /// No description provided for @editNameDisplayLabel.
  ///
  /// In en, this message translates to:
  /// **'DISPLAY NAME'**
  String get editNameDisplayLabel;

  /// No description provided for @editNameSchoolLabel.
  ///
  /// In en, this message translates to:
  /// **'SCHOOL NAME'**
  String get editNameSchoolLabel;

  /// No description provided for @editNameDisplayHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get editNameDisplayHint;

  /// No description provided for @editNameSchoolHint.
  ///
  /// In en, this message translates to:
  /// **'Enter school name'**
  String get editNameSchoolHint;

  /// No description provided for @editNameSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get editNameSaveButton;

  /// No description provided for @goalDialogDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get goalDialogDeleteTitle;

  /// No description provided for @goalDialogDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this goal?'**
  String get goalDialogDeleteBody;

  /// No description provided for @homeNoTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day'**
  String get homeNoTasksTitle;

  /// No description provided for @homeNoTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select another day or add a new deadline'**
  String get homeNoTasksSubtitle;

  /// No description provided for @homeDeadlinesToday.
  ///
  /// In en, this message translates to:
  /// **'Deadlines Today'**
  String get homeDeadlinesToday;

  /// No description provided for @homeStudySessions.
  ///
  /// In en, this message translates to:
  /// **'Study Sessions'**
  String get homeStudySessions;

  /// No description provided for @calendarSectionGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get calendarSectionGoals;

  /// No description provided for @calendarSectionSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get calendarSectionSessions;

  /// No description provided for @calendarNoGoals.
  ///
  /// In en, this message translates to:
  /// **'No goals on this day'**
  String get calendarNoGoals;

  /// No description provided for @calendarNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions on this day'**
  String get calendarNoSessions;

  /// No description provided for @calendarTodayButton.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarTodayButton;

  /// No description provided for @goalTypeExam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get goalTypeExam;

  /// No description provided for @goalTypeTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get goalTypeTest;

  /// No description provided for @goalTypeAssignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get goalTypeAssignment;

  /// No description provided for @goalTypePresentation.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get goalTypePresentation;

  /// No description provided for @goalTypeProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get goalTypeProject;

  /// No description provided for @goalTypePaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get goalTypePaper;

  /// No description provided for @goalTypeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get goalTypeQuiz;

  /// No description provided for @goalTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get goalTypeOther;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyVeryHard.
  ///
  /// In en, this message translates to:
  /// **'Very Hard'**
  String get difficultyVeryHard;

  /// No description provided for @plannedSessionDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration} min'**
  String plannedSessionDuration(int duration);

  /// No description provided for @plannedSessionNoTime.
  ///
  /// In en, this message translates to:
  /// **'No time set'**
  String get plannedSessionNoTime;

  /// No description provided for @progressEditTargetTime.
  ///
  /// In en, this message translates to:
  /// **'Target Time'**
  String get progressEditTargetTime;

  /// No description provided for @progressEditTimeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time Spent'**
  String get progressEditTimeSpent;

  /// No description provided for @progressEditHours.
  ///
  /// In en, this message translates to:
  /// **'HOURS'**
  String get progressEditHours;

  /// No description provided for @progressEditMinutes.
  ///
  /// In en, this message translates to:
  /// **'MINUTES'**
  String get progressEditMinutes;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
