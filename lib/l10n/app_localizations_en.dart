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
  String get sending => 'Sending...';

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
  String get management => 'Management';

  @override
  String get manageShifts => 'Manage Shifts';

  @override
  String get assignVolunteersToShifts => 'Assign volunteers to shifts';

  @override
  String get presenceChecks => 'Presence Checks';

  @override
  String get checkVolunteerAttendance => 'Check volunteer attendance';

  @override
  String get reviewVolunteerLeaveRequests => 'Review volunteer leave requests';

  @override
  String get reportBugsOrSuggestIdeas => 'Report bugs or suggest ideas';

  @override
  String get noEventsAssignedYet => 'No events assigned to your teams yet';

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get teamLeaderDashboard => 'Team Leader Dashboard';

  @override
  String get myEvents => 'My Events';

  @override
  String shiftsAssigned(int count, String plural) {
    return '$count Shift$plural Assigned';
  }

  @override
  String get noShiftsAssignedToYourTeams => 'No shifts assigned to your teams';

  @override
  String get mainShift => 'Main Shift';

  @override
  String get subLocation => 'SubLocation';

  @override
  String membersAssigned(int assigned, int total) {
    return '$assigned/$total members assigned';
  }

  @override
  String get noTeamMembersAvailable => 'No team members available';

  @override
  String get memberAssigned => 'Member assigned';

  @override
  String get memberRemoved => 'Member removed';

  @override
  String get memberAssignedToSublocation => 'Member assigned to sublocation';

  @override
  String get memberRemovedFromSublocation => 'Member removed from sublocation';

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
  String get eventNameRequired => 'Event Name *';

  @override
  String get pleaseEnterEventName => 'Please enter event name';

  @override
  String get eventDescription => 'Event Description';

  @override
  String get description => 'Description';

  @override
  String get startDate => 'Start Date';

  @override
  String get startDateRequired => 'Start Date *';

  @override
  String get endDate => 'End Date';

  @override
  String get endDateRequired => 'End Date *';

  @override
  String get required => 'Required';

  @override
  String get dateFormatHint => 'DD-MM-YYYY';

  @override
  String get eventCreated => 'Event created successfully';

  @override
  String get eventUpdated => 'Event updated successfully';

  @override
  String get eventDeleted => 'Event deleted successfully';

  @override
  String get noEvents => 'No events found';

  @override
  String get noArchivedEvents => 'No archived events';

  @override
  String get noActiveEventsFound =>
      'No active events found.\nTap + to add a new event.';

  @override
  String get selectEvent => 'Select Event';

  @override
  String get viewWorkflow => 'View Workflow';

  @override
  String get archived => 'Archived';

  @override
  String get restored => 'restored';

  @override
  String get deleted => 'deleted';

  @override
  String get addNewEvent => 'Add New Event';

  @override
  String get recurringEvent => 'Recurring Event';

  @override
  String get recurrenceType => 'Recurrence Type';

  @override
  String get recurrenceTypeRequired => 'Recurrence Type *';

  @override
  String get recurrenceEndDate => 'Recurrence End Date (Optional)';

  @override
  String get recurrence => 'Recurrence';

  @override
  String get presenceCheckPermissions => 'Presence Check Permissions';

  @override
  String get presenceCheckPermissionsRequired => 'Presence Check Permissions *';

  @override
  String get to => 'To';

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
  String get noShiftsAdded => 'No shifts added';

  @override
  String get selectShift => 'Select a shift';

  @override
  String get addShift => 'Add Shift';

  @override
  String get location => 'Location';

  @override
  String get locationColon => 'Location:';

  @override
  String get subLocationRequired => 'SubLocation *';

  @override
  String get addSubLocation => 'Add SubLocation';

  @override
  String get editSubLocation => 'Edit SubLocation';

  @override
  String get thisLocationHasNoSublocations =>
      'This location has no sublocations';

  @override
  String get pleaseSelectSublocation => 'Please select a sublocation';

  @override
  String get teamAssignment => 'Team Assignment';

  @override
  String get existing => 'Existing';

  @override
  String get temporary => 'Temporary';

  @override
  String get teamOptional => 'Team (Optional)';

  @override
  String get selectTeam => 'Select Team';

  @override
  String get none => 'None';

  @override
  String get temporaryTeam => 'Temporary Team';

  @override
  String get create => 'Create';

  @override
  String get createTeam => 'Create Team';

  @override
  String get createTemporaryTeam => 'Create Temporary Team';

  @override
  String get leader => 'Leader';

  @override
  String leaderColon(String id) {
    return 'Leader: $id';
  }

  @override
  String get membersColon => 'Members:';

  @override
  String get teamMembers => 'Team Members';

  @override
  String get teamMembersColon => 'Team Members:';

  @override
  String get tapPlusToAddFirstTeamLeader => 'Tap + to add a new team leader';

  @override
  String get noMembers => 'No members';

  @override
  String get noTemporaryTeamCreated => 'No temporary team created';

  @override
  String get selectTeamMember => 'Select Team Member';

  @override
  String get addMember => 'Add';

  @override
  String get selectDays => 'Select Days:';

  @override
  String get dayOfMonth => 'Day of Month';

  @override
  String get dayOfMonthRequired => 'Day of Month *';

  @override
  String get selectDayHint => 'Select day (1-31)';

  @override
  String get day => 'Day';

  @override
  String get dayRequired => 'Day *';

  @override
  String dayNumber(int number) {
    return 'Day $number';
  }

  @override
  String get pleaseSelectDay => 'Please select a day';

  @override
  String get month => 'Month';

  @override
  String get monthRequired => 'Month *';

  @override
  String get pleaseSelectMonth => 'Please select a month';

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
  String get noLocations => 'No locations found';

  @override
  String get selectLocation => 'Select Location';

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
  String get selectEventAndShift => 'Select Event & Shift';

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
    return 'By:';
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
  String get basicInformation => 'Basic Information';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get professionalInformation => 'Professional Information';

  @override
  String get documentInformation => 'Document Information';

  @override
  String get attachments => 'Attachments';

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
  String imageUploaded(String imageName) {
    return 'Image uploaded: $imageName';
  }

  @override
  String errorUploadingImage(String imageName, String error) {
    return 'Error uploading $imageName: $error';
  }

  @override
  String get pdfDownloadedSuccessfully => 'PDF downloaded successfully!';

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
    return 'Average Rating: $rating / 5';
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
  String get notes => 'Notes';

  @override
  String get from => 'From';

  @override
  String get teamLeader => 'Team Leader';

  @override
  String get admin => 'Admin';

  @override
  String get all => 'All';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownName => 'Unknown Name';

  @override
  String get noPhone => 'No Phone';

  @override
  String get volunteersManagement => 'Volunteers Management';

  @override
  String get addVolunteer => 'Add Volunteer';

  @override
  String get editVolunteer => 'Edit Volunteer';

  @override
  String get deleteVolunteer => 'Delete Volunteer';

  @override
  String get archiveVolunteer => 'Archive Volunteer';

  @override
  String get restoreVolunteer => 'Restore Volunteer';

  @override
  String get tapPlusToAddVolunteer => 'Tap + to add a new volunteer';

  @override
  String get assignTeam => 'Assign Team';

  @override
  String selectTeamFor(String name) {
    return 'Select a team for $name:';
  }

  @override
  String get noTeam => 'No team';

  @override
  String assignedToTeam(String name, String teamName) {
    return 'Assigned $name to $teamName';
  }

  @override
  String archiveVolunteerConfirm(String name) {
    return 'Archive $name?\n\nThis will hide the volunteer but keep their data.';
  }

  @override
  String get archive => 'Archive';

  @override
  String get restore => 'Restore';

  @override
  String restoreVolunteerConfirm(String name) {
    return 'Restore $name?';
  }

  @override
  String deleteVolunteerConfirm(String name) {
    return 'Delete $name permanently?\n\nThis action cannot be undone!';
  }

  @override
  String get tapPlusToAddTeam => 'Tap + to add a new team';

  @override
  String get noMembersAdded => 'No members added';

  @override
  String get addTeamMember => 'Add Team Member';

  @override
  String get noVolunteersAvailable => 'No volunteers available';

  @override
  String get added => 'Added';

  @override
  String teamLeaderID(String id) {
    return 'Team Leader ID: $id';
  }

  @override
  String get tapPlusToAddLocation => 'Tap + to add a new location';

  @override
  String get noLocationsFound => 'No locations found';

  @override
  String latLon(String lat, String lon) {
    return 'Lat: $lat, Lon: $lon';
  }

  @override
  String get subLocations => 'Sublocations:';

  @override
  String get subLocationsColon => 'Sub-locations:';

  @override
  String get noSubLocationsAdded => 'No sub-locations added';

  @override
  String get pickLocationOnMap => 'Pick Location on Map';

  @override
  String get pickLocation => 'Pick Location';

  @override
  String get tapOnMapToSelectLocation =>
      'Tap on map or drag marker to select location';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get pickOnMap => 'Pick on Map';

  @override
  String get pleaseSelectTeamLeader => 'Please select a team leader';

  @override
  String get team => 'Team';

  @override
  String teamColon(String name) {
    return 'Team: $name';
  }

  @override
  String get membersColonBold => 'Members:';

  @override
  String get leaderColon2 => 'Leader:';

  @override
  String teamLeaderIDColon(String id) {
    return 'Team Leader ID: $id';
  }

  @override
  String leaderColonWithId(String id) {
    return 'Leader: $id';
  }

  @override
  String latLonCoordinates(String lat, String lon) {
    return 'Lat: $lat, Lon: $lon';
  }

  @override
  String get subLocationsColon2 => 'Sub-locations:';

  @override
  String get noSublocationsAdded => 'No sub-locations added';

  @override
  String get carouselManagement => 'Carousel Management';

  @override
  String get noCarouselImagesYet => 'No carousel images yet';

  @override
  String get tapPlusToAddFirstImage => 'Tap + to add your first image';

  @override
  String get deleteImage => 'Delete Image';

  @override
  String areYouSureDeleteImage(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get imageDeletedSuccessfully => 'Image deleted successfully';

  @override
  String get errorCouldNotReadFile => 'Error: Could not read file';

  @override
  String get imageUploadedSuccessfully => 'Image uploaded successfully!';

  @override
  String uploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get titleAndImageRequired => 'Title and Image URL are required';

  @override
  String get invalidImageURL => 'Invalid Image URL';

  @override
  String get visibleToUsers => 'Visible to Users';

  @override
  String get ratingCriteriaManagement => 'Rating Criteria Management';

  @override
  String get eventWorkflow => 'Event Workflow';

  @override
  String get planning => 'Planning';

  @override
  String get eventCreatedAndScheduled => 'Event created and scheduled';

  @override
  String get eventInPlanningPhase =>
      'Event is in planning phase. You can assign shifts and volunteers.';

  @override
  String get eventIsCurrentlyRunning => 'Event is currently running';

  @override
  String get eventIsActive => 'Event is active. Volunteers can check in/out.';

  @override
  String get eventDateHasPassed => 'Event date has passed';

  @override
  String get eventHasEnded =>
      'Event has ended. You can review attendance and feedback.';

  @override
  String get eventIsArchived => 'Event is archived';

  @override
  String get eventIsArchivedHidden =>
      'Event is archived and hidden from main lists.';

  @override
  String get closed => 'Closed';

  @override
  String submittedDate(String date) {
    return 'Submitted: $date';
  }

  @override
  String reviewedBy(String name) {
    return 'Reviewed by: $name';
  }

  @override
  String get updateStatus => 'Update Status';

  @override
  String get updateFeedbackStatus => 'Update Feedback Status';

  @override
  String get statusColon => 'Status:';

  @override
  String get resolutionNotesOptional => 'Resolution Notes (optional):';

  @override
  String get feedbackUpdatedSuccessfully => 'Feedback updated successfully';

  @override
  String get deleteFeedback => 'Delete Feedback';

  @override
  String get deleteFeedbackConfirmation =>
      'Are you sure you want to delete this feedback? This action cannot be undone.';

  @override
  String get feedbackDeletedSuccessfully => 'Feedback deleted successfully';

  @override
  String get reassignLocation => 'Reassign Location';

  @override
  String get locationReassignedSuccessfully =>
      'Location reassigned successfully. Volunteer must check in at new location.';

  @override
  String eventColon(String name) {
    return 'Event: $name';
  }

  @override
  String shiftTimeRange(String start, String end) {
    return 'Shift: $start - $end';
  }

  @override
  String get selectNewLocation => 'Select new location:';

  @override
  String mainLocationColon(String name) {
    return 'Main Location: $name';
  }

  @override
  String get sublocationsColon => 'Sublocations:';

  @override
  String get reassign => 'Reassign';

  @override
  String get pleaseSelectARole => 'Please select a role';

  @override
  String get pleaseSelectATeam => 'Please select a team';

  @override
  String get pleaseSelectAnEvent => 'Please select an event';

  @override
  String get noUsersFoundForAudience => 'No users found for selected audience';

  @override
  String notificationSentToUsers(int count) {
    return 'Notification sent to $count user(s)';
  }

  @override
  String errorSendingNotifications(String error) {
    return 'Error sending notifications: $error';
  }

  @override
  String get notificationType => 'Notification Type';

  @override
  String get title => 'Title';

  @override
  String get message => 'Message';

  @override
  String get sendTo => 'Send To';

  @override
  String get allUsers => 'All Users';

  @override
  String get byRole => 'By Role';

  @override
  String get byTeam => 'By Team';

  @override
  String get eventParticipants => 'Event Participants';

  @override
  String get selectRole => 'Select Role';

  @override
  String get chooseARole => 'Choose a role';

  @override
  String get chooseATeam => 'Choose a team';

  @override
  String get chooseAnEvent => 'Choose an event';

  @override
  String get sendNotificationsToGroups =>
      'Send notifications to specific groups of users in the system';

  @override
  String get noEventsAvailable => 'No events available';

  @override
  String get chooseEventToViewFeedback => 'Choose an event to view feedback';

  @override
  String get selectEventToViewFeedback => 'Select an event to view feedback';

  @override
  String get noFeedbackReceivedYet => 'No feedback received for this event yet';

  @override
  String errorLoadingAverages(String error) {
    return 'Error loading averages: $error';
  }

  @override
  String individualFeedback(int count) {
    return 'Individual Feedback ($count)';
  }

  @override
  String get overallRating => 'Overall Rating';

  @override
  String basedOnResponses(int count, String plural) {
    return 'Based on $count response$plural';
  }

  @override
  String errorLoadingForms(String error) {
    return 'Error loading forms: $error';
  }

  @override
  String syncedVolunteersWithForms(int count) {
    return 'Synced $count volunteer(s) with their forms';
  }

  @override
  String get volunteerFormsManagement => 'Volunteer Forms Management';

  @override
  String get newForm => 'New Form';

  @override
  String get filterByStatus => 'Filter by status:';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get createNewFormToGetStarted => 'Create a new form to get started';

  @override
  String get documentsColon => 'Documents:';

  @override
  String formNumber(String number) {
    return 'Form #$number';
  }

  @override
  String statusUpdatedButErrorCreatingAccount(String error) {
    return 'Status updated but error creating account: $error';
  }

  @override
  String get enterNotificationTitle => 'Enter notification title';

  @override
  String get enterNotificationMessage => 'Enter notification message';

  @override
  String archiveItem(String itemType) {
    return 'Archive $itemType?';
  }

  @override
  String get unarchive => 'Unarchive';

  @override
  String unarchiveItem(String itemType) {
    return 'Unarchive $itemType?';
  }

  @override
  String deleteItem(String itemType) {
    return 'Delete $itemType?';
  }

  @override
  String confirmArchiveItem(String itemName) {
    return 'Are you sure you want to archive \"$itemName\"?';
  }

  @override
  String confirmUnarchiveItem(String itemName) {
    return 'Are you sure you want to restore \"$itemName\" to active status?';
  }

  @override
  String confirmDeleteItem(String itemName) {
    return 'Are you sure you want to permanently delete \"$itemName\"?';
  }

  @override
  String archiveWarning(String itemType) {
    return 'This will hide the $itemType from active lists but keep all data intact.';
  }

  @override
  String deleteWarning(String itemType) {
    return 'This action cannot be undone. All data associated with this $itemType will be permanently removed.';
  }

  @override
  String get deleteWarningGeneric =>
      'This action cannot be undone! All associated data will be permanently deleted.';

  @override
  String get showArchived => 'Show Archived';

  @override
  String errorOccurred(String error) {
    return 'Error occurred: $error';
  }

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get notificationsWillAppearHere =>
      'You\'ll see notifications here when you get them';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get check1Departure => 'Check 1: Departure';

  @override
  String get check2Arrival => 'Check 2: Arrival';

  @override
  String get selectAnEventToStartPresenceCheck =>
      'Select an event to start presence check';

  @override
  String get adminOnly => 'Admin Only';

  @override
  String get tlOnly => 'TL Only';

  @override
  String get both => 'Both';

  @override
  String get noVolunteersAssignedToThisEvent =>
      'No volunteers assigned to this event';

  @override
  String get departureCheckOnBus => 'Departure Check (On Bus)';

  @override
  String get arrivalCheckOnLocation => 'Arrival Check (On Location)';

  @override
  String get excusedLeaveApproved => 'EXCUSED (Leave Approved)';

  @override
  String get present => 'Present';

  @override
  String get presentUpper => 'PRESENT';

  @override
  String get absent => 'Absent';

  @override
  String get absentUpper => 'ABSENT';

  @override
  String get markAbsent => 'Mark Absent';

  @override
  String get markPresent => 'Mark Present';

  @override
  String get notChecked => 'Not Checked';

  @override
  String get excused => 'Excused';

  @override
  String errorMarkingAttendance(String error) {
    return 'Error marking attendance: $error';
  }

  @override
  String get selectAnEventAndShiftToAssignVolunteers =>
      'Select an event and shift to assign volunteers';

  @override
  String get pleaseSelectEventShiftAndLocationFirst =>
      'Please select an event, shift, and location first';

  @override
  String get noApprovedVolunteersAvailable =>
      'No approved volunteers available';

  @override
  String assignedVolunteersToSubLocation(int count) {
    return 'Assigned $count volunteers to sublocation successfully';
  }

  @override
  String errorCreatingAssignments(String error) {
    return 'Error creating assignments: $error';
  }

  @override
  String get chooseLocationToAssignVolunteers =>
      'Choose location to assign volunteers';

  @override
  String get selectALocation => 'Select a location';

  @override
  String get assignVolunteersToLocation => 'Assign Volunteers to Location';

  @override
  String get assigned => 'assigned';

  @override
  String get noVolunteersAssignedYet => 'No volunteers assigned yet';

  @override
  String get teamLeadersShouldAssignFirst => 'Team leaders should assign first';

  @override
  String get mainSuffix => '(Main)';

  @override
  String get unknownSubLocation => 'Unknown Sublocation';

  @override
  String selectedCount(int count) {
    return 'Selected: $count';
  }

  @override
  String get event => 'Event';

  @override
  String errorReassigningLocation(String error) {
    return 'Error reassigning location: $error';
  }

  @override
  String get contactAdminToAssignYourTeamToEvents =>
      'Contact admin to assign your team to events';

  @override
  String get selectAShiftToAssignVolunteers =>
      'Select a shift to assign volunteers';

  @override
  String get noTeamAssignedToThisLocation =>
      'No team assigned to this location';

  @override
  String get noApprovedVolunteersAvailableInYourTeam =>
      'No approved volunteers available in your team';

  @override
  String get chooseWhichLocationToAssignYourTeamMembersTo =>
      'Choose which location to assign your team members to:';

  @override
  String get requestLeave => 'Request Leave';

  @override
  String get userNotAuthenticated => 'User not authenticated';

  @override
  String get leaveRequestSubmittedSuccessfully =>
      'Leave request submitted successfully';

  @override
  String get reasonForLeaveRequest => 'Reason for Leave Request';

  @override
  String get provideDetailedReasonForLeave =>
      'Please provide a detailed reason for your leave request. This will help your team leader make an informed decision.';

  @override
  String get enterYourReasonHere => 'Enter your reason here...';

  @override
  String get pleaseProvideAReason => 'Please provide a reason';

  @override
  String get pleaseProvideMoreDetailedReason =>
      'Please provide a more detailed reason (at least 10 characters)';

  @override
  String get teamLeaderWillReviewRequest =>
      'Your team leader will review this request. You will be notified of their decision.';

  @override
  String get submitting => 'Submitting...';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get dateLabel => 'Date';

  @override
  String get shiftTimeLabel => 'Shift Time';

  @override
  String get noEventsAssignedToYou => 'No events assigned to you';

  @override
  String get contactTeamLeaderToBeAssignedToEvents =>
      'Contact your team leader to be assigned to events';

  @override
  String get viewOnMap => 'View on Map';

  @override
  String get submitEventFeedback => 'Submit Event Feedback';

  @override
  String contactLabel(String phone) {
    return 'Contact: $phone';
  }

  @override
  String yourShift(String shiftId) {
    return 'Your shift: $shiftId';
  }

  @override
  String locationField(String location) {
    return 'Location: $location';
  }

  @override
  String get notAssigned => 'Not assigned';

  @override
  String get rateYourExperience => 'Rate Your Experience';

  @override
  String get rateEventManagementAspects =>
      'Please rate the following aspects of the event management (1 = Poor, 5 = Excellent)';

  @override
  String get additionalCommentsOptional => 'Additional Comments (Optional)';

  @override
  String get shareAnyAdditionalThoughts =>
      'Share any additional thoughts or suggestions...';

  @override
  String get thankYouForFeedback => 'Thank you for your feedback!';

  @override
  String get poor => 'Poor';

  @override
  String get fair => 'Fair';

  @override
  String get good => 'Good';

  @override
  String get veryGood => 'Very Good';

  @override
  String get excellent => 'Excellent';

  @override
  String get imageSizeExceedsLimit => 'Image size should not exceed 500 KB.';

  @override
  String get formSubmittedForReview => 'Form submitted for review!';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get readyToPrint => 'Ready to print!';

  @override
  String get errorLabel => 'Error';

  @override
  String get sublocation => 'Sublocation';

  @override
  String get organizationPlanning => 'Organization & Planning';

  @override
  String get howWellWasEventOrganized =>
      'How well was the event organized and planned?';

  @override
  String get logisticsResources => 'Logistics & Resources';

  @override
  String get wereResourcesAdequatelyProvided =>
      'Were resources and logistics adequately provided?';

  @override
  String get communication => 'Communication';

  @override
  String get howEffectiveWasCommunication =>
      'How effective was the communication before and during the event?';

  @override
  String get howWellWasEventManaged =>
      'How well was the event managed overall?';

  @override
  String get shareYourThoughts =>
      'Share your thoughts, suggestions, or any issues you experienced...';

  @override
  String get mySchedule => 'My Schedule';

  @override
  String errorLoadingSchedule(String error) {
    return 'Error loading schedule: $error';
  }

  @override
  String get selectDayToViewAssignments => 'Select a day to view assignments';

  @override
  String noShiftsOn(String date) {
    return 'No shifts on $date';
  }

  @override
  String locationId(String id) {
    return 'Location ID: $id';
  }

  @override
  String get performanceScore => 'Performance Score';

  @override
  String get basedOnIHSCriteria => 'Based on IHS Criteria';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get education => 'Education';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get profession => 'Profession';

  @override
  String get jobTitle => 'Job Title';

  @override
  String get department => 'Department';

  @override
  String get notApplicable => 'N/A';

  @override
  String get nextShift => 'NEXT SHIFT';

  @override
  String get unknownLocation => 'Unknown Location';

  @override
  String get provideYourFeedback => 'Provide your feedback about this event';

  @override
  String get howWasYourExperience => 'How was your experience?';

  @override
  String get pleaseSelectRating => 'Please select a rating';

  @override
  String get yourFeedback => 'Your Feedback';

  @override
  String get shareFeedbackDetails => 'Share your feedback details here...';

  @override
  String get pleaseProvideFeedback => 'Please provide your feedback';

  @override
  String get feedbackSubmittedSuccessfully =>
      'Thank you! Your feedback has been submitted successfully.';

  @override
  String failedToSubmitFeedback(String error) {
    return 'Failed to submit feedback: $error';
  }

  @override
  String get eventDetails => 'Event Details';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get areYouSureSignOut => 'Are you sure you want to sign out?';

  @override
  String get shareFeedbackPrompt =>
      'Share your feedback, report bugs, or suggest improvements to help us make the system better.';

  @override
  String get describeFeedbackDetail =>
      'Describe the issue, bug, or suggestion in detail...';

  @override
  String get pleaseEnterFeedback => 'Please enter your feedback';

  @override
  String get provideMoreDetails =>
      'Please provide more details (at least 10 characters)';

  @override
  String get myPreviousFeedback => 'My Previous Feedback';

  @override
  String errorLoadingFeedback(String error) {
    return 'Error loading feedback: $error';
  }

  @override
  String get noFeedbackYet => 'You haven\'t submitted any feedback yet';

  @override
  String get adminResponse => 'Admin Response:';
}
