import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'VMS'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @volunteers.
  ///
  /// In en, this message translates to:
  /// **'Volunteers'**
  String get volunteers;

  /// No description provided for @leaders.
  ///
  /// In en, this message translates to:
  /// **'Leaders'**
  String get leaders;

  /// No description provided for @teamLeaders.
  ///
  /// In en, this message translates to:
  /// **'Team Leaders'**
  String get teamLeaders;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @locations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get locations;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @sendNotif.
  ///
  /// In en, this message translates to:
  /// **'Send Notif'**
  String get sendNotif;

  /// No description provided for @sendNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Notification'**
  String get sendNotification;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {userPhone}'**
  String welcomeBack(String userPhone);

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @workflowScenarios.
  ///
  /// In en, this message translates to:
  /// **'Workflow Scenarios'**
  String get workflowScenarios;

  /// No description provided for @activeEvents.
  ///
  /// In en, this message translates to:
  /// **'Active Events'**
  String get activeEvents;

  /// No description provided for @volunteersPerTeam.
  ///
  /// In en, this message translates to:
  /// **'Volunteers per Team (Top 5)'**
  String get volunteersPerTeam;

  /// No description provided for @noActiveEvents.
  ///
  /// In en, this message translates to:
  /// **'No active events'**
  String get noActiveEvents;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @activityOverview.
  ///
  /// In en, this message translates to:
  /// **'Activity Overview'**
  String get activityOverview;

  /// No description provided for @shiftsCompletedLast6Months.
  ///
  /// In en, this message translates to:
  /// **'Shifts completed in last 6 months'**
  String get shiftsCompletedLast6Months;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @manageShifts.
  ///
  /// In en, this message translates to:
  /// **'Manage Shifts'**
  String get manageShifts;

  /// No description provided for @assignVolunteersToShifts.
  ///
  /// In en, this message translates to:
  /// **'Assign volunteers to shifts'**
  String get assignVolunteersToShifts;

  /// No description provided for @presenceChecks.
  ///
  /// In en, this message translates to:
  /// **'Presence Checks'**
  String get presenceChecks;

  /// No description provided for @checkVolunteerAttendance.
  ///
  /// In en, this message translates to:
  /// **'Check volunteer attendance'**
  String get checkVolunteerAttendance;

  /// No description provided for @reviewVolunteerLeaveRequests.
  ///
  /// In en, this message translates to:
  /// **'Review volunteer leave requests'**
  String get reviewVolunteerLeaveRequests;

  /// No description provided for @reportBugsOrSuggestIdeas.
  ///
  /// In en, this message translates to:
  /// **'Report bugs or suggest ideas'**
  String get reportBugsOrSuggestIdeas;

  /// No description provided for @noEventsAssignedYet.
  ///
  /// In en, this message translates to:
  /// **'No events assigned to your teams yet'**
  String get noEventsAssignedYet;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @teamLeaderDashboard.
  ///
  /// In en, this message translates to:
  /// **'Team Leader Dashboard'**
  String get teamLeaderDashboard;

  /// No description provided for @myEvents.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get myEvents;

  /// No description provided for @shiftsAssigned.
  ///
  /// In en, this message translates to:
  /// **'{count} Shift{plural} Assigned'**
  String shiftsAssigned(int count, String plural);

  /// No description provided for @noShiftsAssignedToYourTeams.
  ///
  /// In en, this message translates to:
  /// **'No shifts assigned to your teams'**
  String get noShiftsAssignedToYourTeams;

  /// No description provided for @mainShift.
  ///
  /// In en, this message translates to:
  /// **'Main Shift'**
  String get mainShift;

  /// No description provided for @subLocation.
  ///
  /// In en, this message translates to:
  /// **'SubLocation'**
  String get subLocation;

  /// No description provided for @membersAssigned.
  ///
  /// In en, this message translates to:
  /// **'{assigned}/{total} members assigned'**
  String membersAssigned(int assigned, int total);

  /// No description provided for @noTeamMembersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No team members available'**
  String get noTeamMembersAvailable;

  /// No description provided for @memberAssigned.
  ///
  /// In en, this message translates to:
  /// **'Member assigned'**
  String get memberAssigned;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get memberRemoved;

  /// No description provided for @memberAssignedToSublocation.
  ///
  /// In en, this message translates to:
  /// **'Member assigned to sublocation'**
  String get memberAssignedToSublocation;

  /// No description provided for @memberRemovedFromSublocation.
  ///
  /// In en, this message translates to:
  /// **'Member removed from sublocation'**
  String get memberRemovedFromSublocation;

  /// No description provided for @activeEventsCount.
  ///
  /// In en, this message translates to:
  /// **'Active Events'**
  String get activeEventsCount;

  /// No description provided for @volunteersCount.
  ///
  /// In en, this message translates to:
  /// **'Volunteers'**
  String get volunteersCount;

  /// No description provided for @teamLeadersCount.
  ///
  /// In en, this message translates to:
  /// **'Team Leaders'**
  String get teamLeadersCount;

  /// No description provided for @notificationsCount.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsCount;

  /// No description provided for @shiftAssignment.
  ///
  /// In en, this message translates to:
  /// **'Shift Assignment'**
  String get shiftAssignment;

  /// No description provided for @presenceCheck.
  ///
  /// In en, this message translates to:
  /// **'Presence Check'**
  String get presenceCheck;

  /// No description provided for @formsMgmt.
  ///
  /// In en, this message translates to:
  /// **'Forms Mgmt'**
  String get formsMgmt;

  /// No description provided for @carouselMgmt.
  ///
  /// In en, this message translates to:
  /// **'Carousel Mgmt'**
  String get carouselMgmt;

  /// No description provided for @ratings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @leaveRequests.
  ///
  /// In en, this message translates to:
  /// **'Leave Requests'**
  String get leaveRequests;

  /// No description provided for @systemFeedback.
  ///
  /// In en, this message translates to:
  /// **'System Feedback'**
  String get systemFeedback;

  /// No description provided for @eventFeedback.
  ///
  /// In en, this message translates to:
  /// **'Event Feedback'**
  String get eventFeedback;

  /// No description provided for @volunteerRegistration.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Registration'**
  String get volunteerRegistration;

  /// No description provided for @volunteerRegistrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage new sign-ups, review forms, and approve volunteers.'**
  String get volunteerRegistrationDescription;

  /// No description provided for @eventManagement.
  ///
  /// In en, this message translates to:
  /// **'Event Management'**
  String get eventManagement;

  /// No description provided for @eventManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Create events, assign shifts, and manage attendance.'**
  String get eventManagementDescription;

  /// No description provided for @startWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Start Workflow'**
  String get startWorkflow;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get members;

  /// No description provided for @volunteerWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Workflow'**
  String get volunteerWorkflow;

  /// No description provided for @statusUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}'**
  String statusUpdatedTo(String status);

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @waitingForVolunteerToFillData.
  ///
  /// In en, this message translates to:
  /// **'Waiting for volunteer to fill data'**
  String get waitingForVolunteerToFillData;

  /// No description provided for @formLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Form link has been sent to the volunteer.'**
  String get formLinkSent;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pendingReview;

  /// No description provided for @adminChecksForm.
  ///
  /// In en, this message translates to:
  /// **'Admin checks form and attachments'**
  String get adminChecksForm;

  /// No description provided for @pleaseReviewForm.
  ///
  /// In en, this message translates to:
  /// **'Please review the form data and attachments.'**
  String get pleaseReviewForm;

  /// No description provided for @viewForm.
  ///
  /// In en, this message translates to:
  /// **'View Form'**
  String get viewForm;

  /// No description provided for @generatingPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get generatingPdf;

  /// No description provided for @pdfDownloaded.
  ///
  /// In en, this message translates to:
  /// **'PDF Downloaded'**
  String get pdfDownloaded;

  /// No description provided for @initialApproval.
  ///
  /// In en, this message translates to:
  /// **'Initial Approval'**
  String get initialApproval;

  /// No description provided for @firstLevelApproval.
  ///
  /// In en, this message translates to:
  /// **'First level approval'**
  String get firstLevelApproval;

  /// No description provided for @formPassedInitialReview.
  ///
  /// In en, this message translates to:
  /// **'Form has passed initial review.'**
  String get formPassedInitialReview;

  /// No description provided for @approveL1.
  ///
  /// In en, this message translates to:
  /// **'Approve (L1)'**
  String get approveL1;

  /// No description provided for @finalApproval.
  ///
  /// In en, this message translates to:
  /// **'Final Approval'**
  String get finalApproval;

  /// No description provided for @secondLevelApproval.
  ///
  /// In en, this message translates to:
  /// **'Second level approval'**
  String get secondLevelApproval;

  /// No description provided for @formPassedFinalReview.
  ///
  /// In en, this message translates to:
  /// **'Form has passed final review.'**
  String get formPassedFinalReview;

  /// No description provided for @approveL2.
  ///
  /// In en, this message translates to:
  /// **'Approve (L2)'**
  String get approveL2;

  /// No description provided for @processFinished.
  ///
  /// In en, this message translates to:
  /// **'Process finished'**
  String get processFinished;

  /// No description provided for @volunteerRegistrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Volunteer registration is complete.'**
  String get volunteerRegistrationComplete;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @reEvaluate.
  ///
  /// In en, this message translates to:
  /// **'Re-evaluate'**
  String get reEvaluate;

  /// No description provided for @volunteerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Dashboard'**
  String get volunteerDashboard;

  /// No description provided for @redirectingToForm.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to form...'**
  String get redirectingToForm;

  /// No description provided for @myAssignments.
  ///
  /// In en, this message translates to:
  /// **'My Assignments'**
  String get myAssignments;

  /// No description provided for @upcomingShift.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Shift'**
  String get upcomingShift;

  /// No description provided for @noUpcomingShifts.
  ///
  /// In en, this message translates to:
  /// **'No upcoming shifts assigned.'**
  String get noUpcomingShifts;

  /// No description provided for @applicationUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Application Under Review'**
  String get applicationUnderReview;

  /// No description provided for @applicationUnderReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Your volunteer application has been submitted and is currently under review. You will be notified once a decision has been made.'**
  String get applicationUnderReviewDesc;

  /// No description provided for @firstLevelApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'First Level Approval'**
  String get firstLevelApprovalTitle;

  /// No description provided for @firstLevelApprovalDesc.
  ///
  /// In en, this message translates to:
  /// **'Your application has been approved at the first level. Waiting for final approval.'**
  String get firstLevelApprovalDesc;

  /// No description provided for @fullyApproved.
  ///
  /// In en, this message translates to:
  /// **'Fully Approved'**
  String get fullyApproved;

  /// No description provided for @fullyApprovedDesc.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your application has been fully approved.'**
  String get fullyApprovedDesc;

  /// No description provided for @activeVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Active Volunteer'**
  String get activeVolunteer;

  /// No description provided for @activeVolunteerDesc.
  ///
  /// In en, this message translates to:
  /// **'You are an active volunteer in the system.'**
  String get activeVolunteerDesc;

  /// No description provided for @applicationRejected.
  ///
  /// In en, this message translates to:
  /// **'Application Rejected'**
  String get applicationRejected;

  /// No description provided for @applicationRejectedFirstStage.
  ///
  /// In en, this message translates to:
  /// **'Your application was rejected at the first review stage.'**
  String get applicationRejectedFirstStage;

  /// No description provided for @applicationRejectedFinalStage.
  ///
  /// In en, this message translates to:
  /// **'Your application was rejected at the final review stage.'**
  String get applicationRejectedFinalStage;

  /// No description provided for @errorLoadingInfo.
  ///
  /// In en, this message translates to:
  /// **'Error loading your information. Please try again.'**
  String get errorLoadingInfo;

  /// No description provided for @noVolunteerFormFound.
  ///
  /// In en, this message translates to:
  /// **'No volunteer form found. Please contact support.'**
  String get noVolunteerFormFound;

  /// No description provided for @myScheduleLocations.
  ///
  /// In en, this message translates to:
  /// **'My Schedule & Locations'**
  String get myScheduleLocations;

  /// No description provided for @viewUpcomingShifts.
  ///
  /// In en, this message translates to:
  /// **'View your upcoming shifts, times, and locations'**
  String get viewUpcomingShifts;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @viewRatingAndInfo.
  ///
  /// In en, this message translates to:
  /// **'View your rating and personal info'**
  String get viewRatingAndInfo;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @reportBugsOrSuggest.
  ///
  /// In en, this message translates to:
  /// **'Report bugs or suggest improvements'**
  String get reportBugsOrSuggest;

  /// No description provided for @welcomeBackName.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBackName;

  /// No description provided for @volunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get volunteer;

  /// No description provided for @eventsManagement.
  ///
  /// In en, this message translates to:
  /// **'Events Management'**
  String get eventsManagement;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEvent;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEvent;

  /// No description provided for @eventName.
  ///
  /// In en, this message translates to:
  /// **'Event Name'**
  String get eventName;

  /// No description provided for @eventNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Event Name *'**
  String get eventNameRequired;

  /// No description provided for @pleaseEnterEventName.
  ///
  /// In en, this message translates to:
  /// **'Please enter event name'**
  String get pleaseEnterEventName;

  /// No description provided for @eventDescription.
  ///
  /// In en, this message translates to:
  /// **'Event Description'**
  String get eventDescription;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @startDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Start Date *'**
  String get startDateRequired;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @endDateRequired.
  ///
  /// In en, this message translates to:
  /// **'End Date *'**
  String get endDateRequired;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @dateFormatHint.
  ///
  /// In en, this message translates to:
  /// **'DD-MM-YYYY'**
  String get dateFormatHint;

  /// No description provided for @eventCreated.
  ///
  /// In en, this message translates to:
  /// **'Event created successfully'**
  String get eventCreated;

  /// No description provided for @eventUpdated.
  ///
  /// In en, this message translates to:
  /// **'Event updated successfully'**
  String get eventUpdated;

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **'Event deleted successfully'**
  String get eventDeleted;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get noEvents;

  /// No description provided for @noArchivedEvents.
  ///
  /// In en, this message translates to:
  /// **'No archived events'**
  String get noArchivedEvents;

  /// No description provided for @noActiveEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No active events found.\nTap + to add a new event.'**
  String get noActiveEventsFound;

  /// No description provided for @selectEvent.
  ///
  /// In en, this message translates to:
  /// **'Select Event'**
  String get selectEvent;

  /// No description provided for @viewWorkflow.
  ///
  /// In en, this message translates to:
  /// **'View Workflow'**
  String get viewWorkflow;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'restored'**
  String get restored;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get deleted;

  /// No description provided for @addNewEvent.
  ///
  /// In en, this message translates to:
  /// **'Add New Event'**
  String get addNewEvent;

  /// No description provided for @recurringEvent.
  ///
  /// In en, this message translates to:
  /// **'Recurring Event'**
  String get recurringEvent;

  /// No description provided for @recurrenceType.
  ///
  /// In en, this message translates to:
  /// **'Recurrence Type'**
  String get recurrenceType;

  /// No description provided for @recurrenceTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Recurrence Type *'**
  String get recurrenceTypeRequired;

  /// No description provided for @recurrenceEndDate.
  ///
  /// In en, this message translates to:
  /// **'Recurrence End Date (Optional)'**
  String get recurrenceEndDate;

  /// No description provided for @recurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get recurrence;

  /// No description provided for @presenceCheckPermissions.
  ///
  /// In en, this message translates to:
  /// **'Presence Check Permissions'**
  String get presenceCheckPermissions;

  /// No description provided for @presenceCheckPermissionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Presence Check Permissions *'**
  String get presenceCheckPermissionsRequired;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @shifts.
  ///
  /// In en, this message translates to:
  /// **'Shifts'**
  String get shifts;

  /// No description provided for @shiftTime.
  ///
  /// In en, this message translates to:
  /// **'Shift Time'**
  String get shiftTime;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @noShifts.
  ///
  /// In en, this message translates to:
  /// **'No shifts available'**
  String get noShifts;

  /// No description provided for @noShiftsAdded.
  ///
  /// In en, this message translates to:
  /// **'No shifts added'**
  String get noShiftsAdded;

  /// No description provided for @selectShift.
  ///
  /// In en, this message translates to:
  /// **'Select a shift'**
  String get selectShift;

  /// No description provided for @addShift.
  ///
  /// In en, this message translates to:
  /// **'Add Shift'**
  String get addShift;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationColon.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get locationColon;

  /// No description provided for @subLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'SubLocation *'**
  String get subLocationRequired;

  /// No description provided for @addSubLocation.
  ///
  /// In en, this message translates to:
  /// **'Add SubLocation'**
  String get addSubLocation;

  /// No description provided for @editSubLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit SubLocation'**
  String get editSubLocation;

  /// No description provided for @thisLocationHasNoSublocations.
  ///
  /// In en, this message translates to:
  /// **'This location has no sublocations'**
  String get thisLocationHasNoSublocations;

  /// No description provided for @pleaseSelectSublocation.
  ///
  /// In en, this message translates to:
  /// **'Please select a sublocation'**
  String get pleaseSelectSublocation;

  /// No description provided for @teamAssignment.
  ///
  /// In en, this message translates to:
  /// **'Team Assignment'**
  String get teamAssignment;

  /// No description provided for @existing.
  ///
  /// In en, this message translates to:
  /// **'Existing'**
  String get existing;

  /// No description provided for @temporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get temporary;

  /// No description provided for @teamOptional.
  ///
  /// In en, this message translates to:
  /// **'Team (Optional)'**
  String get teamOptional;

  /// No description provided for @selectTeam.
  ///
  /// In en, this message translates to:
  /// **'Select Team'**
  String get selectTeam;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @temporaryTeam.
  ///
  /// In en, this message translates to:
  /// **'Temporary Team'**
  String get temporaryTeam;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createTeam.
  ///
  /// In en, this message translates to:
  /// **'Create Team'**
  String get createTeam;

  /// No description provided for @createTemporaryTeam.
  ///
  /// In en, this message translates to:
  /// **'Create Temporary Team'**
  String get createTemporaryTeam;

  /// No description provided for @leader.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get leader;

  /// No description provided for @leaderColon.
  ///
  /// In en, this message translates to:
  /// **'Leader: {id}'**
  String leaderColon(String id);

  /// No description provided for @membersColon.
  ///
  /// In en, this message translates to:
  /// **'Members:'**
  String get membersColon;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// No description provided for @teamMembersColon.
  ///
  /// In en, this message translates to:
  /// **'Team Members:'**
  String get teamMembersColon;

  /// No description provided for @tapPlusToAddFirstTeamLeader.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a new team leader'**
  String get tapPlusToAddFirstTeamLeader;

  /// No description provided for @noMembers.
  ///
  /// In en, this message translates to:
  /// **'No members'**
  String get noMembers;

  /// No description provided for @noTemporaryTeamCreated.
  ///
  /// In en, this message translates to:
  /// **'No temporary team created'**
  String get noTemporaryTeamCreated;

  /// No description provided for @selectTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Select Team Member'**
  String get selectTeamMember;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addMember;

  /// No description provided for @selectDays.
  ///
  /// In en, this message translates to:
  /// **'Select Days:'**
  String get selectDays;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of Month'**
  String get dayOfMonth;

  /// No description provided for @dayOfMonthRequired.
  ///
  /// In en, this message translates to:
  /// **'Day of Month *'**
  String get dayOfMonthRequired;

  /// No description provided for @selectDayHint.
  ///
  /// In en, this message translates to:
  /// **'Select day (1-31)'**
  String get selectDayHint;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @dayRequired.
  ///
  /// In en, this message translates to:
  /// **'Day *'**
  String get dayRequired;

  /// No description provided for @dayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayNumber(int number);

  /// No description provided for @pleaseSelectDay.
  ///
  /// In en, this message translates to:
  /// **'Please select a day'**
  String get pleaseSelectDay;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @monthRequired.
  ///
  /// In en, this message translates to:
  /// **'Month *'**
  String get monthRequired;

  /// No description provided for @pleaseSelectMonth.
  ///
  /// In en, this message translates to:
  /// **'Please select a month'**
  String get pleaseSelectMonth;

  /// No description provided for @teamLeadersManagement.
  ///
  /// In en, this message translates to:
  /// **'Team Leaders Management'**
  String get teamLeadersManagement;

  /// No description provided for @addTeamLeader.
  ///
  /// In en, this message translates to:
  /// **'Add Team Leader'**
  String get addTeamLeader;

  /// No description provided for @editTeamLeader.
  ///
  /// In en, this message translates to:
  /// **'Edit Team Leader'**
  String get editTeamLeader;

  /// No description provided for @deleteTeamLeader.
  ///
  /// In en, this message translates to:
  /// **'Delete Team Leader'**
  String get deleteTeamLeader;

  /// No description provided for @noTeamLeaders.
  ///
  /// In en, this message translates to:
  /// **'No team leaders found'**
  String get noTeamLeaders;

  /// No description provided for @tapPlusToAddTeamLeader.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a new team leader'**
  String get tapPlusToAddTeamLeader;

  /// No description provided for @teamLeaderArchived.
  ///
  /// In en, this message translates to:
  /// **'{name} archived'**
  String teamLeaderArchived(String name);

  /// No description provided for @teamLeaderRestored.
  ///
  /// In en, this message translates to:
  /// **'{name} restored'**
  String teamLeaderRestored(String name);

  /// No description provided for @teamLeaderDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String teamLeaderDeleted(String name);

  /// No description provided for @teamsManagement.
  ///
  /// In en, this message translates to:
  /// **'Teams Management'**
  String get teamsManagement;

  /// No description provided for @addTeam.
  ///
  /// In en, this message translates to:
  /// **'Add Team'**
  String get addTeam;

  /// No description provided for @editTeam.
  ///
  /// In en, this message translates to:
  /// **'Edit Team'**
  String get editTeam;

  /// No description provided for @deleteTeam.
  ///
  /// In en, this message translates to:
  /// **'Delete Team'**
  String get deleteTeam;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team Name'**
  String get teamName;

  /// No description provided for @noTeams.
  ///
  /// In en, this message translates to:
  /// **'No teams found'**
  String get noTeams;

  /// No description provided for @locationsManagement.
  ///
  /// In en, this message translates to:
  /// **'Locations Management'**
  String get locationsManagement;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get addLocation;

  /// No description provided for @editLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit Location'**
  String get editLocation;

  /// No description provided for @deleteLocation.
  ///
  /// In en, this message translates to:
  /// **'Delete Location'**
  String get deleteLocation;

  /// No description provided for @locationName.
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get locationName;

  /// No description provided for @mainLocation.
  ///
  /// In en, this message translates to:
  /// **'Main Location'**
  String get mainLocation;

  /// No description provided for @noLocations.
  ///
  /// In en, this message translates to:
  /// **'No locations found'**
  String get noLocations;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @assignMyTeam.
  ///
  /// In en, this message translates to:
  /// **'Assign My Team'**
  String get assignMyTeam;

  /// No description provided for @unableToIdentifyCurrentUser.
  ///
  /// In en, this message translates to:
  /// **'Unable to identify current user'**
  String get unableToIdentifyCurrentUser;

  /// No description provided for @noEventsAssignedToYourTeams.
  ///
  /// In en, this message translates to:
  /// **'No events assigned to your teams'**
  String get noEventsAssignedToYourTeams;

  /// No description provided for @contactAdminToAssignYourTeam.
  ///
  /// In en, this message translates to:
  /// **'Contact admin to assign your team to events'**
  String get contactAdminToAssignYourTeam;

  /// No description provided for @selectEventAndShift.
  ///
  /// In en, this message translates to:
  /// **'Select Event & Shift'**
  String get selectEventAndShift;

  /// No description provided for @eventsWhereYourTeamIsAssigned.
  ///
  /// In en, this message translates to:
  /// **'Events where your team is assigned'**
  String get eventsWhereYourTeamIsAssigned;

  /// No description provided for @selectLocationToAssign.
  ///
  /// In en, this message translates to:
  /// **'Select Location to Assign'**
  String get selectLocationToAssign;

  /// No description provided for @chooseLocationToAssignTeam.
  ///
  /// In en, this message translates to:
  /// **'Choose which location to assign your team members to:'**
  String get chooseLocationToAssignTeam;

  /// No description provided for @assignVolunteers.
  ///
  /// In en, this message translates to:
  /// **'Assign Volunteers'**
  String get assignVolunteers;

  /// No description provided for @currentAssignments.
  ///
  /// In en, this message translates to:
  /// **'Current Assignments'**
  String get currentAssignments;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'By:'**
  String by(String assignedBy);

  /// No description provided for @selectVolunteers.
  ///
  /// In en, this message translates to:
  /// **'Select Volunteers'**
  String get selectVolunteers;

  /// No description provided for @pleaseSelectEventShiftLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select an event, shift, and location first'**
  String get pleaseSelectEventShiftLocation;

  /// No description provided for @noTeamAssignedToLocation.
  ///
  /// In en, this message translates to:
  /// **'No team assigned to this location'**
  String get noTeamAssignedToLocation;

  /// No description provided for @noApprovedVolunteersInTeam.
  ///
  /// In en, this message translates to:
  /// **'No approved volunteers available in your team'**
  String get noApprovedVolunteersInTeam;

  /// No description provided for @assignedVolunteersSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Assigned {count} volunteers successfully'**
  String assignedVolunteersSuccessfully(int count);

  /// No description provided for @leaveRequestsManagement.
  ///
  /// In en, this message translates to:
  /// **'Leave Requests'**
  String get leaveRequestsManagement;

  /// No description provided for @leaveRequestApproved.
  ///
  /// In en, this message translates to:
  /// **'Leave request approved'**
  String get leaveRequestApproved;

  /// No description provided for @leaveRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Leave request rejected'**
  String get leaveRequestRejected;

  /// No description provided for @selectAnEventToViewRequests.
  ///
  /// In en, this message translates to:
  /// **'Select an event to view leave requests'**
  String get selectAnEventToViewRequests;

  /// No description provided for @pendingLeaveRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Leave Requests'**
  String get pendingLeaveRequests;

  /// No description provided for @noPendingLeaveRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending leave requests'**
  String get noPendingLeaveRequests;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason:'**
  String get reason;

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested: {date}'**
  String requested(String date);

  /// No description provided for @volunteerForm.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Form'**
  String get volunteerForm;

  /// No description provided for @editVolunteerForm.
  ///
  /// In en, this message translates to:
  /// **'Edit Volunteer Form'**
  String get editVolunteerForm;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @professionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Professional Information'**
  String get professionalInformation;

  /// No description provided for @documentInformation.
  ///
  /// In en, this message translates to:
  /// **'Document Information'**
  String get documentInformation;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @createPdf.
  ///
  /// In en, this message translates to:
  /// **'إنشاء PDF'**
  String get createPdf;

  /// No description provided for @formCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Form created successfully! Volunteer can now login.'**
  String get formCreatedSuccessfully;

  /// No description provided for @formUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Form updated successfully!'**
  String get formUpdatedSuccessfully;

  /// No description provided for @imageSizeExceeds500KB.
  ///
  /// In en, this message translates to:
  /// **'Image size should not exceed 500 KB.'**
  String get imageSizeExceeds500KB;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(String error);

  /// No description provided for @uploadingImages.
  ///
  /// In en, this message translates to:
  /// **'Uploading images...'**
  String get uploadingImages;

  /// No description provided for @imageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded: {imageName}'**
  String imageUploaded(String imageName);

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading {imageName}: {error}'**
  String errorUploadingImage(String imageName, String error);

  /// No description provided for @pdfDownloadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PDF downloaded successfully!'**
  String get pdfDownloadedSuccessfully;

  /// No description provided for @errorDownloading.
  ///
  /// In en, this message translates to:
  /// **'Error downloading: {error}'**
  String errorDownloading(String error);

  /// No description provided for @errorPrinting.
  ///
  /// In en, this message translates to:
  /// **'Error printing: {error}'**
  String errorPrinting(String error);

  /// No description provided for @existingImage.
  ///
  /// In en, this message translates to:
  /// **'Existing image'**
  String get existingImage;

  /// No description provided for @rateVolunteers.
  ///
  /// In en, this message translates to:
  /// **'Rate Volunteers'**
  String get rateVolunteers;

  /// No description provided for @noVolunteersFound.
  ///
  /// In en, this message translates to:
  /// **'No volunteers found'**
  String get noVolunteersFound;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @notRated.
  ///
  /// In en, this message translates to:
  /// **'Not rated'**
  String get notRated;

  /// No description provided for @lastRated.
  ///
  /// In en, this message translates to:
  /// **'Last: {date}'**
  String lastRated(String date);

  /// No description provided for @pleaseConfigureCriteriaFirst.
  ///
  /// In en, this message translates to:
  /// **'Please configure rating criteria first'**
  String get pleaseConfigureCriteriaFirst;

  /// No description provided for @ratingCriteria.
  ///
  /// In en, this message translates to:
  /// **'Rating Criteria'**
  String get ratingCriteria;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get addNote;

  /// No description provided for @saveRating.
  ///
  /// In en, this message translates to:
  /// **'Save Rating'**
  String get saveRating;

  /// No description provided for @ratingSaved.
  ///
  /// In en, this message translates to:
  /// **'Rating saved for {name}'**
  String ratingSaved(String name);

  /// No description provided for @errorSavingRating.
  ///
  /// In en, this message translates to:
  /// **'Error saving rating: {error}'**
  String errorSavingRating(String error);

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating: {rating} / 5'**
  String averageRating(String rating);

  /// No description provided for @manageRatingCriteria.
  ///
  /// In en, this message translates to:
  /// **'Manage Rating Criteria'**
  String get manageRatingCriteria;

  /// No description provided for @noCriteriaDefined.
  ///
  /// In en, this message translates to:
  /// **'No criteria defined'**
  String get noCriteriaDefined;

  /// No description provided for @clickPlusToAddCriteria.
  ///
  /// In en, this message translates to:
  /// **'Click the + button to add criteria'**
  String get clickPlusToAddCriteria;

  /// No description provided for @addNewCriterion.
  ///
  /// In en, this message translates to:
  /// **'Add New Criterion'**
  String get addNewCriterion;

  /// No description provided for @criterionName.
  ///
  /// In en, this message translates to:
  /// **'Criterion Name'**
  String get criterionName;

  /// No description provided for @criterionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., Communication Skills'**
  String get criterionPlaceholder;

  /// No description provided for @criterionAdded.
  ///
  /// In en, this message translates to:
  /// **'Criterion added. Don\'t forget to save!'**
  String get criterionAdded;

  /// No description provided for @editCriterion.
  ///
  /// In en, this message translates to:
  /// **'Edit Criterion'**
  String get editCriterion;

  /// No description provided for @criterionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Criterion updated. Don\'t forget to save!'**
  String get criterionUpdated;

  /// No description provided for @deleteCriterion.
  ///
  /// In en, this message translates to:
  /// **'Delete Criterion'**
  String get deleteCriterion;

  /// No description provided for @confirmDeleteCriterion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String confirmDeleteCriterion(String name);

  /// No description provided for @criterionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Criterion deleted. Don\'t forget to save!'**
  String get criterionDeleted;

  /// No description provided for @cannotSaveEmptyCriteria.
  ///
  /// In en, this message translates to:
  /// **'Cannot save empty criteria list'**
  String get cannotSaveEmptyCriteria;

  /// No description provided for @ratingCriteriaSaved.
  ///
  /// In en, this message translates to:
  /// **'Rating criteria saved successfully'**
  String get ratingCriteriaSaved;

  /// No description provided for @errorSavingCriteria.
  ///
  /// In en, this message translates to:
  /// **'Error saving criteria: {error}'**
  String errorSavingCriteria(String error);

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangedSuccessfully;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @wrongCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get wrongCurrentPassword;

  /// No description provided for @passwordSecurityTips.
  ///
  /// In en, this message translates to:
  /// **'Password Security Tips:'**
  String get passwordSecurityTips;

  /// No description provided for @volunteerManagementSystem.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Management System'**
  String get volunteerManagementSystem;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @seedDevelopmentData.
  ///
  /// In en, this message translates to:
  /// **'Seed Development Data'**
  String get seedDevelopmentData;

  /// No description provided for @manageSystemFeedback.
  ///
  /// In en, this message translates to:
  /// **'Manage System Feedback'**
  String get manageSystemFeedback;

  /// No description provided for @allFeedback.
  ///
  /// In en, this message translates to:
  /// **'All Feedback'**
  String get allFeedback;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @feedbackType.
  ///
  /// In en, this message translates to:
  /// **'Feedback Type'**
  String get feedbackType;

  /// No description provided for @bugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get bugReport;

  /// No description provided for @featureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get featureRequest;

  /// No description provided for @improvement.
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get improvement;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @teamLeader.
  ///
  /// In en, this message translates to:
  /// **'Team Leader'**
  String get teamLeader;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownName.
  ///
  /// In en, this message translates to:
  /// **'Unknown Name'**
  String get unknownName;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No Phone'**
  String get noPhone;

  /// No description provided for @volunteersManagement.
  ///
  /// In en, this message translates to:
  /// **'Volunteers Management'**
  String get volunteersManagement;

  /// No description provided for @addVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Add Volunteer'**
  String get addVolunteer;

  /// No description provided for @editVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Edit Volunteer'**
  String get editVolunteer;

  /// No description provided for @deleteVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Delete Volunteer'**
  String get deleteVolunteer;

  /// No description provided for @archiveVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Archive Volunteer'**
  String get archiveVolunteer;

  /// No description provided for @restoreVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Restore Volunteer'**
  String get restoreVolunteer;

  /// No description provided for @tapPlusToAddVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a new volunteer'**
  String get tapPlusToAddVolunteer;

  /// No description provided for @assignTeam.
  ///
  /// In en, this message translates to:
  /// **'Assign Team'**
  String get assignTeam;

  /// No description provided for @selectTeamFor.
  ///
  /// In en, this message translates to:
  /// **'Select a team for {name}:'**
  String selectTeamFor(String name);

  /// No description provided for @noTeam.
  ///
  /// In en, this message translates to:
  /// **'No team'**
  String get noTeam;

  /// No description provided for @assignedToTeam.
  ///
  /// In en, this message translates to:
  /// **'Assigned {name} to {teamName}'**
  String assignedToTeam(String name, String teamName);

  /// No description provided for @archiveVolunteerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive {name}?\n\nThis will hide the volunteer but keep their data.'**
  String archiveVolunteerConfirm(String name);

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreVolunteerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore {name}?'**
  String restoreVolunteerConfirm(String name);

  /// No description provided for @deleteVolunteerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} permanently?\n\nThis action cannot be undone!'**
  String deleteVolunteerConfirm(String name);

  /// No description provided for @tapPlusToAddTeam.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a new team'**
  String get tapPlusToAddTeam;

  /// No description provided for @noMembersAdded.
  ///
  /// In en, this message translates to:
  /// **'No members added'**
  String get noMembersAdded;

  /// No description provided for @addTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Add Team Member'**
  String get addTeamMember;

  /// No description provided for @noVolunteersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No volunteers available'**
  String get noVolunteersAvailable;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @teamLeaderID.
  ///
  /// In en, this message translates to:
  /// **'Team Leader ID: {id}'**
  String teamLeaderID(String id);

  /// No description provided for @tapPlusToAddLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a new location'**
  String get tapPlusToAddLocation;

  /// No description provided for @noLocationsFound.
  ///
  /// In en, this message translates to:
  /// **'No locations found'**
  String get noLocationsFound;

  /// No description provided for @latLon.
  ///
  /// In en, this message translates to:
  /// **'Lat: {lat}, Lon: {lon}'**
  String latLon(String lat, String lon);

  /// No description provided for @subLocations.
  ///
  /// In en, this message translates to:
  /// **'Sublocations:'**
  String get subLocations;

  /// No description provided for @subLocationsColon.
  ///
  /// In en, this message translates to:
  /// **'Sub-locations:'**
  String get subLocationsColon;

  /// No description provided for @noSubLocationsAdded.
  ///
  /// In en, this message translates to:
  /// **'No sub-locations added'**
  String get noSubLocationsAdded;

  /// No description provided for @pickLocationOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick Location on Map'**
  String get pickLocationOnMap;

  /// No description provided for @pickLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick Location'**
  String get pickLocation;

  /// No description provided for @tapOnMapToSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap on map or drag marker to select location'**
  String get tapOnMapToSelectLocation;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// No description provided for @pickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on Map'**
  String get pickOnMap;

  /// No description provided for @pleaseSelectTeamLeader.
  ///
  /// In en, this message translates to:
  /// **'Please select a team leader'**
  String get pleaseSelectTeamLeader;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @teamColon.
  ///
  /// In en, this message translates to:
  /// **'Team: {name}'**
  String teamColon(String name);

  /// No description provided for @membersColonBold.
  ///
  /// In en, this message translates to:
  /// **'Members:'**
  String get membersColonBold;

  /// No description provided for @leaderColon2.
  ///
  /// In en, this message translates to:
  /// **'Leader:'**
  String get leaderColon2;

  /// No description provided for @teamLeaderIDColon.
  ///
  /// In en, this message translates to:
  /// **'Team Leader ID: {id}'**
  String teamLeaderIDColon(String id);

  /// No description provided for @leaderColonWithId.
  ///
  /// In en, this message translates to:
  /// **'Leader: {id}'**
  String leaderColonWithId(String id);

  /// No description provided for @latLonCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Lat: {lat}, Lon: {lon}'**
  String latLonCoordinates(String lat, String lon);

  /// No description provided for @subLocationsColon2.
  ///
  /// In en, this message translates to:
  /// **'Sub-locations:'**
  String get subLocationsColon2;

  /// No description provided for @noSublocationsAdded.
  ///
  /// In en, this message translates to:
  /// **'No sub-locations added'**
  String get noSublocationsAdded;

  /// No description provided for @carouselManagement.
  ///
  /// In en, this message translates to:
  /// **'Carousel Management'**
  String get carouselManagement;

  /// No description provided for @noCarouselImagesYet.
  ///
  /// In en, this message translates to:
  /// **'No carousel images yet'**
  String get noCarouselImagesYet;

  /// No description provided for @tapPlusToAddFirstImage.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first image'**
  String get tapPlusToAddFirstImage;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get deleteImage;

  /// No description provided for @areYouSureDeleteImage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String areYouSureDeleteImage(String title);

  /// No description provided for @imageDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image deleted successfully'**
  String get imageDeletedSuccessfully;

  /// No description provided for @errorCouldNotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not read file'**
  String get errorCouldNotReadFile;

  /// No description provided for @imageUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully!'**
  String get imageUploadedSuccessfully;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(String error);

  /// No description provided for @titleAndImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Title and Image URL are required'**
  String get titleAndImageRequired;

  /// No description provided for @invalidImageURL.
  ///
  /// In en, this message translates to:
  /// **'Invalid Image URL'**
  String get invalidImageURL;

  /// No description provided for @visibleToUsers.
  ///
  /// In en, this message translates to:
  /// **'Visible to Users'**
  String get visibleToUsers;

  /// No description provided for @ratingCriteriaManagement.
  ///
  /// In en, this message translates to:
  /// **'Rating Criteria Management'**
  String get ratingCriteriaManagement;

  /// No description provided for @eventWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Event Workflow'**
  String get eventWorkflow;

  /// No description provided for @planning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get planning;

  /// No description provided for @eventCreatedAndScheduled.
  ///
  /// In en, this message translates to:
  /// **'Event created and scheduled'**
  String get eventCreatedAndScheduled;

  /// No description provided for @eventInPlanningPhase.
  ///
  /// In en, this message translates to:
  /// **'Event is in planning phase. You can assign shifts and volunteers.'**
  String get eventInPlanningPhase;

  /// No description provided for @eventIsCurrentlyRunning.
  ///
  /// In en, this message translates to:
  /// **'Event is currently running'**
  String get eventIsCurrentlyRunning;

  /// No description provided for @eventIsActive.
  ///
  /// In en, this message translates to:
  /// **'Event is active. Volunteers can check in/out.'**
  String get eventIsActive;

  /// No description provided for @eventDateHasPassed.
  ///
  /// In en, this message translates to:
  /// **'Event date has passed'**
  String get eventDateHasPassed;

  /// No description provided for @eventHasEnded.
  ///
  /// In en, this message translates to:
  /// **'Event has ended. You can review attendance and feedback.'**
  String get eventHasEnded;

  /// No description provided for @eventIsArchived.
  ///
  /// In en, this message translates to:
  /// **'Event is archived'**
  String get eventIsArchived;

  /// No description provided for @eventIsArchivedHidden.
  ///
  /// In en, this message translates to:
  /// **'Event is archived and hidden from main lists.'**
  String get eventIsArchivedHidden;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @submittedDate.
  ///
  /// In en, this message translates to:
  /// **'Submitted: {date}'**
  String submittedDate(String date);

  /// No description provided for @reviewedBy.
  ///
  /// In en, this message translates to:
  /// **'Reviewed by: {name}'**
  String reviewedBy(String name);

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @updateFeedbackStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Feedback Status'**
  String get updateFeedbackStatus;

  /// No description provided for @statusColon.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get statusColon;

  /// No description provided for @resolutionNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Resolution Notes (optional):'**
  String get resolutionNotesOptional;

  /// No description provided for @feedbackUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Feedback updated successfully'**
  String get feedbackUpdatedSuccessfully;

  /// No description provided for @deleteFeedback.
  ///
  /// In en, this message translates to:
  /// **'Delete Feedback'**
  String get deleteFeedback;

  /// No description provided for @deleteFeedbackConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this feedback? This action cannot be undone.'**
  String get deleteFeedbackConfirmation;

  /// No description provided for @feedbackDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Feedback deleted successfully'**
  String get feedbackDeletedSuccessfully;

  /// No description provided for @reassignLocation.
  ///
  /// In en, this message translates to:
  /// **'Reassign Location'**
  String get reassignLocation;

  /// No description provided for @locationReassignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Location reassigned successfully. Volunteer must check in at new location.'**
  String get locationReassignedSuccessfully;

  /// No description provided for @eventColon.
  ///
  /// In en, this message translates to:
  /// **'Event: {name}'**
  String eventColon(String name);

  /// No description provided for @shiftTimeRange.
  ///
  /// In en, this message translates to:
  /// **'Shift: {start} - {end}'**
  String shiftTimeRange(String start, String end);

  /// No description provided for @selectNewLocation.
  ///
  /// In en, this message translates to:
  /// **'Select new location:'**
  String get selectNewLocation;

  /// No description provided for @mainLocationColon.
  ///
  /// In en, this message translates to:
  /// **'Main Location: {name}'**
  String mainLocationColon(String name);

  /// No description provided for @sublocationsColon.
  ///
  /// In en, this message translates to:
  /// **'Sublocations:'**
  String get sublocationsColon;

  /// No description provided for @reassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get reassign;

  /// No description provided for @pleaseSelectARole.
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get pleaseSelectARole;

  /// No description provided for @pleaseSelectATeam.
  ///
  /// In en, this message translates to:
  /// **'Please select a team'**
  String get pleaseSelectATeam;

  /// No description provided for @pleaseSelectAnEvent.
  ///
  /// In en, this message translates to:
  /// **'Please select an event'**
  String get pleaseSelectAnEvent;

  /// No description provided for @noUsersFoundForAudience.
  ///
  /// In en, this message translates to:
  /// **'No users found for selected audience'**
  String get noUsersFoundForAudience;

  /// No description provided for @notificationSentToUsers.
  ///
  /// In en, this message translates to:
  /// **'Notification sent to {count} user(s)'**
  String notificationSentToUsers(int count);

  /// No description provided for @errorSendingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error sending notifications: {error}'**
  String errorSendingNotifications(String error);

  /// No description provided for @notificationType.
  ///
  /// In en, this message translates to:
  /// **'Notification Type'**
  String get notificationType;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @sendTo.
  ///
  /// In en, this message translates to:
  /// **'Send To'**
  String get sendTo;

  /// No description provided for @allUsers.
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get allUsers;

  /// No description provided for @byRole.
  ///
  /// In en, this message translates to:
  /// **'By Role'**
  String get byRole;

  /// No description provided for @byTeam.
  ///
  /// In en, this message translates to:
  /// **'By Team'**
  String get byTeam;

  /// No description provided for @eventParticipants.
  ///
  /// In en, this message translates to:
  /// **'Event Participants'**
  String get eventParticipants;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @chooseARole.
  ///
  /// In en, this message translates to:
  /// **'Choose a role'**
  String get chooseARole;

  /// No description provided for @chooseATeam.
  ///
  /// In en, this message translates to:
  /// **'Choose a team'**
  String get chooseATeam;

  /// No description provided for @chooseAnEvent.
  ///
  /// In en, this message translates to:
  /// **'Choose an event'**
  String get chooseAnEvent;

  /// No description provided for @sendNotificationsToGroups.
  ///
  /// In en, this message translates to:
  /// **'Send notifications to specific groups of users in the system'**
  String get sendNotificationsToGroups;

  /// No description provided for @noEventsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No events available'**
  String get noEventsAvailable;

  /// No description provided for @chooseEventToViewFeedback.
  ///
  /// In en, this message translates to:
  /// **'Choose an event to view feedback'**
  String get chooseEventToViewFeedback;

  /// No description provided for @selectEventToViewFeedback.
  ///
  /// In en, this message translates to:
  /// **'Select an event to view feedback'**
  String get selectEventToViewFeedback;

  /// No description provided for @noFeedbackReceivedYet.
  ///
  /// In en, this message translates to:
  /// **'No feedback received for this event yet'**
  String get noFeedbackReceivedYet;

  /// No description provided for @errorLoadingAverages.
  ///
  /// In en, this message translates to:
  /// **'Error loading averages: {error}'**
  String errorLoadingAverages(String error);

  /// No description provided for @individualFeedback.
  ///
  /// In en, this message translates to:
  /// **'Individual Feedback ({count})'**
  String individualFeedback(int count);

  /// No description provided for @overallRating.
  ///
  /// In en, this message translates to:
  /// **'Overall Rating'**
  String get overallRating;

  /// No description provided for @basedOnResponses.
  ///
  /// In en, this message translates to:
  /// **'Based on {count} response{plural}'**
  String basedOnResponses(int count, String plural);

  /// No description provided for @errorLoadingForms.
  ///
  /// In en, this message translates to:
  /// **'Error loading forms: {error}'**
  String errorLoadingForms(String error);

  /// No description provided for @syncedVolunteersWithForms.
  ///
  /// In en, this message translates to:
  /// **'Synced {count} volunteer(s) with their forms'**
  String syncedVolunteersWithForms(int count);

  /// No description provided for @volunteerFormsManagement.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Forms Management'**
  String get volunteerFormsManagement;

  /// No description provided for @newForm.
  ///
  /// In en, this message translates to:
  /// **'New Form'**
  String get newForm;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by status:'**
  String get filterByStatus;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @createNewFormToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Create a new form to get started'**
  String get createNewFormToGetStarted;

  /// No description provided for @documentsColon.
  ///
  /// In en, this message translates to:
  /// **'Documents:'**
  String get documentsColon;

  /// No description provided for @formNumber.
  ///
  /// In en, this message translates to:
  /// **'Form #{number}'**
  String formNumber(String number);

  /// No description provided for @statusUpdatedButErrorCreatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Status updated but error creating account: {error}'**
  String statusUpdatedButErrorCreatingAccount(String error);

  /// No description provided for @enterNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter notification title'**
  String get enterNotificationTitle;

  /// No description provided for @enterNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter notification message'**
  String get enterNotificationMessage;

  /// No description provided for @archiveItem.
  ///
  /// In en, this message translates to:
  /// **'Archive {itemType}?'**
  String archiveItem(String itemType);

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @unarchiveItem.
  ///
  /// In en, this message translates to:
  /// **'Unarchive {itemType}?'**
  String unarchiveItem(String itemType);

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete {itemType}?'**
  String deleteItem(String itemType);

  /// No description provided for @confirmArchiveItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to archive \"{itemName}\"?'**
  String confirmArchiveItem(String itemName);

  /// No description provided for @confirmUnarchiveItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore \"{itemName}\" to active status?'**
  String confirmUnarchiveItem(String itemName);

  /// No description provided for @confirmDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete \"{itemName}\"?'**
  String confirmDeleteItem(String itemName);

  /// No description provided for @archiveWarning.
  ///
  /// In en, this message translates to:
  /// **'This will hide the {itemType} from active lists but keep all data intact.'**
  String archiveWarning(String itemType);

  /// No description provided for @deleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All data associated with this {itemType} will be permanently removed.'**
  String deleteWarning(String itemType);

  /// No description provided for @deleteWarningGeneric.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone! All associated data will be permanently deleted.'**
  String get deleteWarningGeneric;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show Archived'**
  String get showArchived;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred: {error}'**
  String errorOccurred(String error);

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see notifications here when you get them'**
  String get notificationsWillAppearHere;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @check1Departure.
  ///
  /// In en, this message translates to:
  /// **'Check 1: Departure'**
  String get check1Departure;

  /// No description provided for @check2Arrival.
  ///
  /// In en, this message translates to:
  /// **'Check 2: Arrival'**
  String get check2Arrival;

  /// No description provided for @selectAnEventToStartPresenceCheck.
  ///
  /// In en, this message translates to:
  /// **'Select an event to start presence check'**
  String get selectAnEventToStartPresenceCheck;

  /// No description provided for @adminOnly.
  ///
  /// In en, this message translates to:
  /// **'Admin Only'**
  String get adminOnly;

  /// No description provided for @tlOnly.
  ///
  /// In en, this message translates to:
  /// **'TL Only'**
  String get tlOnly;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @noVolunteersAssignedToThisEvent.
  ///
  /// In en, this message translates to:
  /// **'No volunteers assigned to this event'**
  String get noVolunteersAssignedToThisEvent;

  /// No description provided for @departureCheckOnBus.
  ///
  /// In en, this message translates to:
  /// **'Departure Check (On Bus)'**
  String get departureCheckOnBus;

  /// No description provided for @arrivalCheckOnLocation.
  ///
  /// In en, this message translates to:
  /// **'Arrival Check (On Location)'**
  String get arrivalCheckOnLocation;

  /// No description provided for @excusedLeaveApproved.
  ///
  /// In en, this message translates to:
  /// **'EXCUSED (Leave Approved)'**
  String get excusedLeaveApproved;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @presentUpper.
  ///
  /// In en, this message translates to:
  /// **'PRESENT'**
  String get presentUpper;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @absentUpper.
  ///
  /// In en, this message translates to:
  /// **'ABSENT'**
  String get absentUpper;

  /// No description provided for @markAbsent.
  ///
  /// In en, this message translates to:
  /// **'Mark Absent'**
  String get markAbsent;

  /// No description provided for @markPresent.
  ///
  /// In en, this message translates to:
  /// **'Mark Present'**
  String get markPresent;

  /// No description provided for @notChecked.
  ///
  /// In en, this message translates to:
  /// **'Not Checked'**
  String get notChecked;

  /// No description provided for @excused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get excused;

  /// No description provided for @errorMarkingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Error marking attendance: {error}'**
  String errorMarkingAttendance(String error);

  /// No description provided for @selectAnEventAndShiftToAssignVolunteers.
  ///
  /// In en, this message translates to:
  /// **'Select an event and shift to assign volunteers'**
  String get selectAnEventAndShiftToAssignVolunteers;

  /// No description provided for @pleaseSelectEventShiftAndLocationFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select an event, shift, and location first'**
  String get pleaseSelectEventShiftAndLocationFirst;

  /// No description provided for @noApprovedVolunteersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No approved volunteers available'**
  String get noApprovedVolunteersAvailable;

  /// No description provided for @assignedVolunteersToSubLocation.
  ///
  /// In en, this message translates to:
  /// **'Assigned {count} volunteers to sublocation successfully'**
  String assignedVolunteersToSubLocation(int count);

  /// No description provided for @errorCreatingAssignments.
  ///
  /// In en, this message translates to:
  /// **'Error creating assignments: {error}'**
  String errorCreatingAssignments(String error);

  /// No description provided for @chooseLocationToAssignVolunteers.
  ///
  /// In en, this message translates to:
  /// **'Choose location to assign volunteers'**
  String get chooseLocationToAssignVolunteers;

  /// No description provided for @selectALocation.
  ///
  /// In en, this message translates to:
  /// **'Select a location'**
  String get selectALocation;

  /// No description provided for @assignVolunteersToLocation.
  ///
  /// In en, this message translates to:
  /// **'Assign Volunteers to Location'**
  String get assignVolunteersToLocation;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'assigned'**
  String get assigned;

  /// No description provided for @noVolunteersAssignedYet.
  ///
  /// In en, this message translates to:
  /// **'No volunteers assigned yet'**
  String get noVolunteersAssignedYet;

  /// No description provided for @teamLeadersShouldAssignFirst.
  ///
  /// In en, this message translates to:
  /// **'Team leaders should assign first'**
  String get teamLeadersShouldAssignFirst;

  /// No description provided for @mainSuffix.
  ///
  /// In en, this message translates to:
  /// **'(Main)'**
  String get mainSuffix;

  /// No description provided for @unknownSubLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown Sublocation'**
  String get unknownSubLocation;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count}'**
  String selectedCount(int count);

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @errorReassigningLocation.
  ///
  /// In en, this message translates to:
  /// **'Error reassigning location: {error}'**
  String errorReassigningLocation(String error);

  /// No description provided for @contactAdminToAssignYourTeamToEvents.
  ///
  /// In en, this message translates to:
  /// **'Contact admin to assign your team to events'**
  String get contactAdminToAssignYourTeamToEvents;

  /// No description provided for @selectAShiftToAssignVolunteers.
  ///
  /// In en, this message translates to:
  /// **'Select a shift to assign volunteers'**
  String get selectAShiftToAssignVolunteers;

  /// No description provided for @noTeamAssignedToThisLocation.
  ///
  /// In en, this message translates to:
  /// **'No team assigned to this location'**
  String get noTeamAssignedToThisLocation;

  /// No description provided for @noApprovedVolunteersAvailableInYourTeam.
  ///
  /// In en, this message translates to:
  /// **'No approved volunteers available in your team'**
  String get noApprovedVolunteersAvailableInYourTeam;

  /// No description provided for @chooseWhichLocationToAssignYourTeamMembersTo.
  ///
  /// In en, this message translates to:
  /// **'Choose which location to assign your team members to:'**
  String get chooseWhichLocationToAssignYourTeamMembersTo;

  /// No description provided for @requestLeave.
  ///
  /// In en, this message translates to:
  /// **'Request Leave'**
  String get requestLeave;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// No description provided for @leaveRequestSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Leave request submitted successfully'**
  String get leaveRequestSubmittedSuccessfully;

  /// No description provided for @reasonForLeaveRequest.
  ///
  /// In en, this message translates to:
  /// **'Reason for Leave Request'**
  String get reasonForLeaveRequest;

  /// No description provided for @provideDetailedReasonForLeave.
  ///
  /// In en, this message translates to:
  /// **'Please provide a detailed reason for your leave request. This will help your team leader make an informed decision.'**
  String get provideDetailedReasonForLeave;

  /// No description provided for @enterYourReasonHere.
  ///
  /// In en, this message translates to:
  /// **'Enter your reason here...'**
  String get enterYourReasonHere;

  /// No description provided for @pleaseProvideAReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason'**
  String get pleaseProvideAReason;

  /// No description provided for @pleaseProvideMoreDetailedReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a more detailed reason (at least 10 characters)'**
  String get pleaseProvideMoreDetailedReason;

  /// No description provided for @teamLeaderWillReviewRequest.
  ///
  /// In en, this message translates to:
  /// **'Your team leader will review this request. You will be notified of their decision.'**
  String get teamLeaderWillReviewRequest;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @shiftTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Shift Time'**
  String get shiftTimeLabel;

  /// No description provided for @noEventsAssignedToYou.
  ///
  /// In en, this message translates to:
  /// **'No events assigned to you'**
  String get noEventsAssignedToYou;

  /// No description provided for @contactTeamLeaderToBeAssignedToEvents.
  ///
  /// In en, this message translates to:
  /// **'Contact your team leader to be assigned to events'**
  String get contactTeamLeaderToBeAssignedToEvents;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// No description provided for @submitEventFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Event Feedback'**
  String get submitEventFeedback;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact: {phone}'**
  String contactLabel(String phone);

  /// No description provided for @yourShift.
  ///
  /// In en, this message translates to:
  /// **'Your shift: {shiftId}'**
  String yourShift(String shiftId);

  /// No description provided for @locationField.
  ///
  /// In en, this message translates to:
  /// **'Location: {location}'**
  String locationField(String location);

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get notAssigned;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get rateYourExperience;

  /// No description provided for @rateEventManagementAspects.
  ///
  /// In en, this message translates to:
  /// **'Please rate the following aspects of the event management (1 = Poor, 5 = Excellent)'**
  String get rateEventManagementAspects;

  /// No description provided for @additionalCommentsOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional Comments (Optional)'**
  String get additionalCommentsOptional;

  /// No description provided for @shareAnyAdditionalThoughts.
  ///
  /// In en, this message translates to:
  /// **'Share any additional thoughts or suggestions...'**
  String get shareAnyAdditionalThoughts;

  /// No description provided for @thankYouForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForFeedback;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get veryGood;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @imageSizeExceedsLimit.
  ///
  /// In en, this message translates to:
  /// **'Image size should not exceed 500 KB.'**
  String get imageSizeExceedsLimit;

  /// No description provided for @formSubmittedForReview.
  ///
  /// In en, this message translates to:
  /// **'Form submitted for review!'**
  String get formSubmittedForReview;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @readyToPrint.
  ///
  /// In en, this message translates to:
  /// **'Ready to print!'**
  String get readyToPrint;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @sublocation.
  ///
  /// In en, this message translates to:
  /// **'Sublocation'**
  String get sublocation;

  /// No description provided for @organizationPlanning.
  ///
  /// In en, this message translates to:
  /// **'Organization & Planning'**
  String get organizationPlanning;

  /// No description provided for @howWellWasEventOrganized.
  ///
  /// In en, this message translates to:
  /// **'How well was the event organized and planned?'**
  String get howWellWasEventOrganized;

  /// No description provided for @logisticsResources.
  ///
  /// In en, this message translates to:
  /// **'Logistics & Resources'**
  String get logisticsResources;

  /// No description provided for @wereResourcesAdequatelyProvided.
  ///
  /// In en, this message translates to:
  /// **'Were resources and logistics adequately provided?'**
  String get wereResourcesAdequatelyProvided;

  /// No description provided for @communication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get communication;

  /// No description provided for @howEffectiveWasCommunication.
  ///
  /// In en, this message translates to:
  /// **'How effective was the communication before and during the event?'**
  String get howEffectiveWasCommunication;

  /// No description provided for @howWellWasEventManaged.
  ///
  /// In en, this message translates to:
  /// **'How well was the event managed overall?'**
  String get howWellWasEventManaged;

  /// No description provided for @shareYourThoughts.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts, suggestions, or any issues you experienced...'**
  String get shareYourThoughts;

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// No description provided for @errorLoadingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Error loading schedule: {error}'**
  String errorLoadingSchedule(String error);

  /// No description provided for @selectDayToViewAssignments.
  ///
  /// In en, this message translates to:
  /// **'Select a day to view assignments'**
  String get selectDayToViewAssignments;

  /// No description provided for @noShiftsOn.
  ///
  /// In en, this message translates to:
  /// **'No shifts on {date}'**
  String noShiftsOn(String date);

  /// No description provided for @locationId.
  ///
  /// In en, this message translates to:
  /// **'Location ID: {id}'**
  String locationId(String id);

  /// No description provided for @performanceScore.
  ///
  /// In en, this message translates to:
  /// **'Performance Score'**
  String get performanceScore;

  /// No description provided for @basedOnIHSCriteria.
  ///
  /// In en, this message translates to:
  /// **'Based on IHS Criteria'**
  String get basedOnIHSCriteria;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @profession.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get profession;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @notApplicable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notApplicable;

  /// No description provided for @nextShift.
  ///
  /// In en, this message translates to:
  /// **'NEXT SHIFT'**
  String get nextShift;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get unknownLocation;

  /// No description provided for @provideYourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Provide your feedback about this event'**
  String get provideYourFeedback;

  /// No description provided for @howWasYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get howWasYourExperience;

  /// No description provided for @pleaseSelectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectRating;

  /// No description provided for @yourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Your Feedback'**
  String get yourFeedback;

  /// No description provided for @shareFeedbackDetails.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback details here...'**
  String get shareFeedbackDetails;

  /// No description provided for @pleaseProvideFeedback.
  ///
  /// In en, this message translates to:
  /// **'Please provide your feedback'**
  String get pleaseProvideFeedback;

  /// No description provided for @feedbackSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your feedback has been submitted successfully.'**
  String get feedbackSubmittedSuccessfully;

  /// No description provided for @failedToSubmitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit feedback: {error}'**
  String failedToSubmitFeedback(String error);

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @areYouSureSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureSignOut;

  /// No description provided for @shareFeedbackPrompt.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback, report bugs, or suggest improvements to help us make the system better.'**
  String get shareFeedbackPrompt;

  /// No description provided for @describeFeedbackDetail.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue, bug, or suggestion in detail...'**
  String get describeFeedbackDetail;

  /// No description provided for @pleaseEnterFeedback.
  ///
  /// In en, this message translates to:
  /// **'Please enter your feedback'**
  String get pleaseEnterFeedback;

  /// No description provided for @provideMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Please provide more details (at least 10 characters)'**
  String get provideMoreDetails;

  /// No description provided for @myPreviousFeedback.
  ///
  /// In en, this message translates to:
  /// **'My Previous Feedback'**
  String get myPreviousFeedback;

  /// No description provided for @errorLoadingFeedback.
  ///
  /// In en, this message translates to:
  /// **'Error loading feedback: {error}'**
  String errorLoadingFeedback(String error);

  /// No description provided for @noFeedbackYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t submitted any feedback yet'**
  String get noFeedbackYet;

  /// No description provided for @adminResponse.
  ///
  /// In en, this message translates to:
  /// **'Admin Response:'**
  String get adminResponse;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
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
