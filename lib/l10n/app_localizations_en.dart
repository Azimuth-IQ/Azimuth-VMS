// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VMS';

  @override
  String get welcome => 'Welcome';

  @override
  String get search => 'Search';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get update => 'Update';

  @override
  String get submit => 'Submit';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signIn => 'Sign In';

  @override
  String get changePassword => 'Change Password';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Retry';

  @override
  String get upload => 'Upload';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get download => 'Download';

  @override
  String get print => 'Print';

  @override
  String get select => 'Select';

  @override
  String get selected => 'Selected';

  @override
  String get assign => 'Assign';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get completed => 'Completed';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get send => 'Send';

  @override
  String get view => 'View';

  @override
  String get refresh => 'Refresh';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get home => 'Home';

  @override
  String get events => 'Events';

  @override
  String get volunteers => 'Volunteers';

  @override
  String get leaders => 'Leaders';

  @override
  String get teamLeaders => 'Team Leaders';

  @override
  String get teams => 'Teams';

  @override
  String get locations => 'Locations';

  @override
  String get notifications => 'Notifications';

  @override
  String get sendNotif => 'Send Notif';

  @override
  String get sendNotification => 'Send Notification';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String welcomeBack(String userPhone) {
    return 'Welcome back, $userPhone';
  }

  @override
  String get analytics => 'Analytics';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get workflowScenarios => 'Workflow Scenarios';

  @override
  String get activeEvents => 'Active Events';

  @override
  String get volunteersPerTeam => 'Volunteers per Team (Top 5)';

  @override
  String get noActiveEvents => 'No active events';

  @override
  String get activity => 'Activity';

  @override
  String get actions => 'Actions';

  @override
  String get activityOverview => 'Activity Overview';

  @override
  String get shiftsCompletedLast6Months => 'Shifts completed in last 6 months';

  @override
  String get activeEventsCount => 'Active Events';

  @override
  String get volunteersCount => 'Volunteers';

  @override
  String get teamLeadersCount => 'Team Leaders';

  @override
  String get notificationsCount => 'Notifications';

  @override
  String get shiftAssignment => 'Shift Assignment';

  @override
  String get presenceCheck => 'Presence Check';

  @override
  String get formsMgmt => 'Forms Mgmt';

  @override
  String get carouselMgmt => 'Carousel Mgmt';

  @override
  String get ratings => 'Ratings';

  @override
  String get leaveRequests => 'Leave Requests';

  @override
  String get systemFeedback => 'System Feedback';

  @override
  String get eventFeedback => 'Event Feedback';

  @override
  String get volunteerRegistration => 'Volunteer Registration';

  @override
  String get volunteerRegistrationDescription =>
      'Manage new sign-ups, review forms, and approve volunteers.';

  @override
  String get eventManagement => 'Event Management';

  @override
  String get eventManagementDescription =>
      'Create events, assign shifts, and manage attendance.';

  @override
  String get startWorkflow => 'Start Workflow';

  @override
  String get members => 'members';

  @override
  String get volunteerWorkflow => 'Volunteer Workflow';

  @override
  String statusUpdatedTo(String status) {
    return 'Status updated to $status';
  }

  @override
  String get sent => 'Sent';

  @override
  String get waitingForVolunteerToFillData =>
      'Waiting for volunteer to fill data';

  @override
  String get formLinkSent => 'Form link has been sent to the volunteer.';

  @override
  String get pendingReview => 'Pending Review';

  @override
  String get adminChecksForm => 'Admin checks form and attachments';

  @override
  String get pleaseReviewForm => 'Please review the form data and attachments.';

  @override
  String get viewForm => 'View Form';

  @override
  String get generatingPdf => 'Generating PDF...';

  @override
  String get pdfDownloaded => 'PDF Downloaded';

  @override
  String get initialApproval => 'Initial Approval';

  @override
  String get firstLevelApproval => 'First level approval';

  @override
  String get formPassedInitialReview => 'Form has passed initial review.';

  @override
  String get approveL1 => 'Approve (L1)';

  @override
  String get finalApproval => 'Final Approval';

  @override
  String get secondLevelApproval => 'Second level approval';

  @override
  String get formPassedFinalReview => 'Form has passed final review.';

  @override
  String get approveL2 => 'Approve (L2)';

  @override
  String get processFinished => 'Process finished';

  @override
  String get volunteerRegistrationComplete =>
      'Volunteer registration is complete.';

  @override
  String get complete => 'Complete';

  @override
  String get reEvaluate => 'Re-evaluate';

  @override
  String get volunteerDashboard => 'Volunteer Dashboard';

  @override
  String get redirectingToForm => 'Redirecting to form...';

  @override
  String get myAssignments => 'My Assignments';

  @override
  String get upcomingShift => 'Upcoming Shift';

  @override
  String get noUpcomingShifts => 'No upcoming shifts assigned.';

  @override
  String get applicationUnderReview => 'Application Under Review';

  @override
  String get applicationUnderReviewDesc =>
      'Your volunteer application has been submitted and is currently under review. You will be notified once a decision has been made.';

  @override
  String get firstLevelApprovalTitle => 'First Level Approval';

  @override
  String get firstLevelApprovalDesc =>
      'Your application has been approved at the first level. Waiting for final approval.';

  @override
  String get fullyApproved => 'Fully Approved';

  @override
  String get fullyApprovedDesc =>
      'Congratulations! Your application has been fully approved.';

  @override
  String get activeVolunteer => 'Active Volunteer';

  @override
  String get activeVolunteerDesc =>
      'You are an active volunteer in the system.';

  @override
  String get applicationRejected => 'Application Rejected';

  @override
  String get applicationRejectedFirstStage =>
      'Your application was rejected at the first review stage.';

  @override
  String get applicationRejectedFinalStage =>
      'Your application was rejected at the final review stage.';

  @override
  String get errorLoadingInfo =>
      'Error loading your information. Please try again.';

  @override
  String get noVolunteerFormFound =>
      'No volunteer form found. Please contact support.';

  @override
  String get myScheduleLocations => 'My Schedule & Locations';

  @override
  String get viewUpcomingShifts =>
      'View your upcoming shifts, times, and locations';

  @override
  String get myProfile => 'My Profile';

  @override
  String get viewRatingAndInfo => 'View your rating and personal info';

  @override
  String get submitFeedback => 'Submit Feedback';

  @override
  String get reportBugsOrSuggest => 'Report bugs or suggest improvements';

  @override
  String get welcomeBackName => 'Welcome back,';

  @override
  String get volunteer => 'Volunteer';

  @override
  String get eventsManagement => 'Events Management';

  @override
  String get createEvent => 'Create Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get eventName => 'Event Name';

  @override
  String get eventDescription => 'Event Description';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get eventCreated => 'Event created successfully';

  @override
  String get eventUpdated => 'Event updated successfully';

  @override
  String get eventDeleted => 'Event deleted successfully';

  @override
  String get noEvents => 'No events found';

  @override
  String get selectEvent => 'Select Event';

  @override
  String get shifts => 'Shifts';

  @override
  String get shiftTime => 'Shift Time';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get shift => 'Shift';

  @override
  String get noShifts => 'No shifts available';

  @override
  String get selectShift => 'Select a shift';

  @override
  String get teamLeadersManagement => 'Team Leaders Management';

  @override
  String get addTeamLeader => 'Add Team Leader';

  @override
  String get editTeamLeader => 'Edit Team Leader';

  @override
  String get deleteTeamLeader => 'Delete Team Leader';

  @override
  String get noTeamLeaders => 'No team leaders found';

  @override
  String get tapPlusToAddTeamLeader => 'Tap + to add a new team leader';

  @override
  String teamLeaderArchived(String name) {
    return '$name archived';
  }

  @override
  String teamLeaderRestored(String name) {
    return '$name restored';
  }

  @override
  String teamLeaderDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get teamsManagement => 'Teams Management';

  @override
  String get addTeam => 'Add Team';

  @override
  String get editTeam => 'Edit Team';

  @override
  String get deleteTeam => 'Delete Team';

  @override
  String get teamName => 'Team Name';

  @override
  String get noTeams => 'No teams found';

  @override
  String get locationsManagement => 'Locations Management';

  @override
  String get addLocation => 'Add Location';

  @override
  String get editLocation => 'Edit Location';

  @override
  String get deleteLocation => 'Delete Location';

  @override
  String get locationName => 'Location Name';

  @override
  String get mainLocation => 'Main Location';

  @override
  String get subLocation => 'Sub Location';

  @override
  String get noLocations => 'No locations found';

  @override
  String get selectLocation => 'Select a location';

  @override
  String get location => 'Location';

  @override
  String get assignMyTeam => 'Assign My Team';

  @override
  String get unableToIdentifyCurrentUser => 'Unable to identify current user';

  @override
  String get noEventsAssignedToYourTeams => 'No events assigned to your teams';

  @override
  String get contactAdminToAssignYourTeam =>
      'Contact admin to assign your team to events';

  @override
  String get selectEventAndShift => 'Select a shift to assign volunteers';

  @override
  String get myEvents => 'My Events';

  @override
  String get eventsWhereYourTeamIsAssigned =>
      'Events where your team is assigned';

  @override
  String get selectLocationToAssign => 'Select Location to Assign';

  @override
  String get chooseLocationToAssignTeam =>
      'Choose which location to assign your team members to:';

  @override
  String get assignVolunteers => 'Assign Volunteers';

  @override
  String get currentAssignments => 'Current Assignments';

  @override
  String by(String assignedBy) {
    return 'By: $assignedBy';
  }

  @override
  String get selectVolunteers => 'Select Volunteers';

  @override
  String get pleaseSelectEventShiftLocation =>
      'Please select an event, shift, and location first';

  @override
  String get noTeamAssignedToLocation => 'No team assigned to this location';

  @override
  String get noApprovedVolunteersInTeam =>
      'No approved volunteers available in your team';

  @override
  String assignedVolunteersSuccessfully(int count) {
    return 'Assigned $count volunteers successfully';
  }

  @override
  String get leaveRequestsManagement => 'Leave Requests';

  @override
  String get leaveRequestApproved => 'Leave request approved';

  @override
  String get leaveRequestRejected => 'Leave request rejected';

  @override
  String get selectAnEventToViewRequests =>
      'Select an event to view leave requests';

  @override
  String get pendingLeaveRequests => 'Pending Leave Requests';

  @override
  String get noPendingLeaveRequests => 'No pending leave requests';

  @override
  String get reason => 'Reason:';

  @override
  String requested(String date) {
    return 'Requested: $date';
  }

  @override
  String get volunteerForm => 'Volunteer Form';

  @override
  String get editVolunteerForm => 'Edit Volunteer Form';

  @override
  String get basicInformation => 'المعلومات الأساسية';

  @override
  String get contactInformation => 'معلومات الاتصال';

  @override
  String get professionalInformation => 'المعلومات المهنية';

  @override
  String get documentInformation => 'معلومات الوثائق';

  @override
  String get attachments => 'المرفقات';

  @override
  String get createPdf => 'إنشاء PDF';

  @override
  String get formCreatedSuccessfully =>
      'Form created successfully! Volunteer can now login.';

  @override
  String get formUpdatedSuccessfully => 'Form updated successfully!';

  @override
  String get imageSizeExceeds500KB => 'Image size should not exceed 500 KB.';

  @override
  String errorPickingImage(String error) {
    return 'Error picking image: $error';
  }

  @override
  String get uploadingImages => 'Uploading images...';

  @override
  String imageUploaded(String name) {
    return 'Image uploaded: $name';
  }

  @override
  String errorUploadingImage(String name, String error) {
    return 'Error uploading $name: $error';
  }

  @override
  String get pdfDownloadedSuccessfully => 'تم تحميل ملف PDF بنجاح!';

  @override
  String errorDownloading(String error) {
    return 'Error downloading: $error';
  }

  @override
  String errorPrinting(String error) {
    return 'Error printing: $error';
  }

  @override
  String get existingImage => 'Existing image';

  @override
  String get rateVolunteers => 'Rate Volunteers';

  @override
  String get noVolunteersFound => 'No volunteers found';

  @override
  String get rate => 'Rate';

  @override
  String get notRated => 'Not rated';

  @override
  String lastRated(String date) {
    return 'Last: $date';
  }

  @override
  String get pleaseConfigureCriteriaFirst =>
      'Please configure rating criteria first';

  @override
  String get ratingCriteria => 'Rating Criteria';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get addNote => 'Add a note...';

  @override
  String get saveRating => 'Save Rating';

  @override
  String ratingSaved(String name) {
    return 'Rating saved for $name';
  }

  @override
  String errorSavingRating(String error) {
    return 'Error saving rating: $error';
  }

  @override
  String averageRating(String rating) {
    return 'Average: $rating/5';
  }

  @override
  String get manageRatingCriteria => 'Manage Rating Criteria';

  @override
  String get noCriteriaDefined => 'No criteria defined';

  @override
  String get clickPlusToAddCriteria => 'Click the + button to add criteria';

  @override
  String get addNewCriterion => 'Add New Criterion';

  @override
  String get criterionName => 'Criterion Name';

  @override
  String get criterionPlaceholder => 'e.g., Communication Skills';

  @override
  String get criterionAdded => 'Criterion added. Don\'t forget to save!';

  @override
  String get editCriterion => 'Edit Criterion';

  @override
  String get criterionUpdated => 'Criterion updated. Don\'t forget to save!';

  @override
  String get deleteCriterion => 'Delete Criterion';

  @override
  String confirmDeleteCriterion(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get criterionDeleted => 'Criterion deleted. Don\'t forget to save!';

  @override
  String get cannotSaveEmptyCriteria => 'Cannot save empty criteria list';

  @override
  String get ratingCriteriaSaved => 'Rating criteria saved successfully';

  @override
  String errorSavingCriteria(String error) {
    return 'Error saving criteria: $error';
  }

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully!';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get wrongCurrentPassword => 'Current password is incorrect';

  @override
  String get passwordSecurityTips => 'Password Security Tips:';

  @override
  String get volunteerManagementSystem => 'Volunteer Management System';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get seedDevelopmentData => 'Seed Development Data';

  @override
  String get manageSystemFeedback => 'Manage System Feedback';

  @override
  String get allFeedback => 'All Feedback';

  @override
  String get inProgress => 'In Progress';

  @override
  String get resolved => 'Resolved';

  @override
  String get feedbackType => 'Feedback Type';

  @override
  String get bugReport => 'Bug Report';

  @override
  String get featureRequest => 'Feature Request';

  @override
  String get improvement => 'Improvement';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get notFound => 'Not found';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get status => 'Status';

  @override
  String get description => 'Description';

  @override
  String get notes => 'Notes';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get teamLeader => 'Team Leader';

  @override
  String get admin => 'Admin';

  @override
  String get all => 'All';

  @override
  String get none => 'None';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownName => 'Unknown Name';

  @override
  String get noPhone => 'No Phone';
}
