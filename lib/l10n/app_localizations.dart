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
  /// **'Complete onboarding flow for new volunteers including form submission, review, and approval'**
  String get volunteerRegistrationDescription;

  /// No description provided for @eventManagement.
  ///
  /// In en, this message translates to:
  /// **'Event Management'**
  String get eventManagement;

  /// No description provided for @eventManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Create events with recurrence, assign teams, manage shifts, and track attendance'**
  String get eventManagementDescription;

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

  /// No description provided for @eventDescription.
  ///
  /// In en, this message translates to:
  /// **'Event Description'**
  String get eventDescription;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

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

  /// No description provided for @selectEvent.
  ///
  /// In en, this message translates to:
  /// **'Select Event'**
  String get selectEvent;

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

  /// No description provided for @selectShift.
  ///
  /// In en, this message translates to:
  /// **'Select a shift'**
  String get selectShift;

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

  /// No description provided for @subLocation.
  ///
  /// In en, this message translates to:
  /// **'Sub Location'**
  String get subLocation;

  /// No description provided for @noLocations.
  ///
  /// In en, this message translates to:
  /// **'No locations found'**
  String get noLocations;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select a location'**
  String get selectLocation;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

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
  /// **'Select a shift to assign volunteers'**
  String get selectEventAndShift;

  /// No description provided for @myEvents.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get myEvents;

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
  /// **'By: {assignedBy}'**
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
  /// **'المعلومات الأساسية'**
  String get basicInformation;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'معلومات الاتصال'**
  String get contactInformation;

  /// No description provided for @professionalInformation.
  ///
  /// In en, this message translates to:
  /// **'المعلومات المهنية'**
  String get professionalInformation;

  /// No description provided for @documentInformation.
  ///
  /// In en, this message translates to:
  /// **'معلومات الوثائق'**
  String get documentInformation;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'المرفقات'**
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
  /// **'Image uploaded: {name}'**
  String imageUploaded(String name);

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading {name}: {error}'**
  String errorUploadingImage(String name, String error);

  /// No description provided for @pdfDownloadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'تم تحميل ملف PDF بنجاح!'**
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
  /// **'Average: {rating}/5'**
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

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

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

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @volunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get volunteer;

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

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

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
