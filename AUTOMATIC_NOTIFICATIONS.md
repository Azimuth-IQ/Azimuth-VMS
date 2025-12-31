# Automatic Notifications Documentation

**Last Updated:** December 31, 2025

---

## Overview

This document provides a comprehensive overview of all automatic notifications implemented in the VMS (Volunteer Management System). Notifications are sent via Firebase Cloud Messaging (FCM) and stored in Firebase Realtime Database under `/ihs/systemusers/{userPhone}/notifications/`.

---

## ✅ Currently Implemented Automatic Notifications (13 Total)

### 1. Shift Assignment Notifications

#### 1.1 Volunteer Shift Assignment

- **Trigger:** When admin or team leader assigns a volunteer to a shift
- **Recipient:** Volunteer
- **Notification Type:** `Info`
- **Title:** "Shift Assignment"
- **Message:** "You have been assigned to {eventName} at {shiftTime}"
- **Implementation:**
  - **Helper Method:** `sendVolunteerAssignmentNotification()`
  - **Called In:**
    - [ShiftAssignmentScreen.dart](lib/UI/AdminScreens/ShiftAssignmentScreen.dart) (Line ~143)
    - [TeamLeaderShiftManagementScreen.dart](lib/UI/TeamLeadersScreens/TeamLeaderShiftManagementScreen.dart) (Line ~199)

#### 1.2 Team Leader Event Assignment ✅

- **Trigger:** When admin creates/updates event with shifts assigned to teams
- **Recipient:** Team Leader
- **Notification Type:** `Alert`
- **Title:** "New Event Assignment"
- **Message:** "You have been assigned to manage volunteers for event: {eventName}"
- **Implementation:**
  - **Helper Method:** `sendShiftAssignmentNotificationToTeamLeader()`
  - **Called In:** [EventsProvider.dart](lib/Providers/EventsProvider.dart) - `createEvent()` and `updateEvent()` methods
  - **Status:** ✅ NOW IMPLEMENTED

---

### 2. Leave Request Notifications

#### 2.1 Leave Request Submitted

- **Trigger:** When volunteer requests leave from a shift
- **Recipient:** Team Leader
- **Notification Type:** `Warning`
- **Title:** "Leave Request"
- **Message:** "{volunteerName} has requested leave from {eventName}"
- **Implementation:**
  - **Helper Method:** `sendLeaveRequestNotificationToTeamLeader()`
  - **Called In:** [LeaveRequestScreen.dart](lib/UI/VolunteerScreens/LeaveRequestScreen.dart) (Line ~77)

#### 2.2 Leave Request Approved

- **Trigger:** When team leader approves a leave request
- **Recipient:** Volunteer
- **Notification Type:** `Info`
- **Title:** "Leave Request Approved"
- **Message:** "Your leave request for {eventName} has been approved"
- **Implementation:**
  - **Helper Method:** `sendLeaveApprovedNotification()`
  - **Called In:** [LeaveRequestManagementScreen.dart](lib/UI/TeamLeadersScreens/LeaveRequestManagementScreen.dart) (Line ~122)

#### 2.3 Leave Request Rejected

- **Trigger:** When team leader rejects a leave request
- **Recipient:** Volunteer
- **Notification Type:** `Warning`
- **Title:** "Leave Request Rejected"
- **Message:** "Your leave request for {eventName} has been rejected"
- **Implementation:**
  - **Helper Method:** `sendLeaveRejectedNotification()`
  - **Called In:** [LeaveRequestManagementScreen.dart](lib/UI/TeamLeadersScreens/LeaveRequestManagementScreen.dart) (Line ~143)

---

### 3. Location Reassignment Notification

- **Trigger:** When admin relocates volunteer to new location/sublocation during an event
- **Recipient:** Volunteer
- **Notification Type:** `Alert`
- **Title:** "Location Change"
- **Message:** "Your location for {eventName} has been changed to {newLocationName}"
- **Implementation:**
  - **Helper Method:** `sendLocationReassignmentNotification()`
  - **Called In:** [LocationReassignmentDialog.dart](lib/UI/AdminScreens/LocationReassignmentDialog.dart) (Line ~85)

---

### 4. Form Status Notifications ✅ NEW

#### 4.1 Form Approved ✅

- **Trigger:** When admin approves volunteer registration form (Approved1 or Approved2)
- **Recipient:** Volunteer
- **Notification Type:** `Info`
- **Title:** "Registration Approved"
- **Message:** "Congratulations {volunteerName}! Your volunteer registration has been approved. You can now log in with your phone number."
- **Implementation:**
  - **Helper Method:** `sendFormApprovedNotification()`
  - **Called In:** [FormMgmt.dart](lib/UI/AdminScreens/FormMgmt.dart) - `_updateFormStatus()` method
  - **Status:** ✅ NOW IMPLEMENTED

#### 4.2 Form Rejected ✅

- **Trigger:** When admin rejects volunteer registration form (Rejected1 or Rejected2)
- **Recipient:** Volunteer
- **Notification Type:** `Warning`
- **Title:** "Registration Status Update"
- **Message:** "Dear {volunteerName}, your volunteer registration requires additional review. Please contact the administrator."
- **Implementation:**
  - **Helper Method:** `sendFormRejectedNotification()`
  - **Called In:** [FormMgmt.dart](lib/UI/AdminScreens/FormMgmt.dart) - `_updateFormStatus()` method
  - **Status:** ✅ NOW IMPLEMENTED

---

### 5. Event Management Notifications ✅ NEW

#### 5.1 New Event Created ✅

- **Trigger:** When admin creates a new event
- **Recipient:** All Team Leaders
- **Notification Type:** `Info`
- **Title:** "New Event Created"
- **Message:** "A new event '{eventName}' has been scheduled for {date}"
- **Implementation:**
  - **Helper Method:** `sendNewEventNotification()`
  - **Called In:** [EventsProvider.dart](lib/Providers/EventsProvider.dart) - `createEvent()` method
  - **Status:** ✅ NOW IMPLEMENTED

#### 5.2 Event Updated ✅

- **Trigger:** When admin updates event details
- **Recipient:** All assigned volunteers
- **Notification Type:** `Alert`
- **Title:** "Event Updated"
- **Message:** "Event '{eventName}' has been updated. Please review the new details."
- **Implementation:**
  - **Helper Method:** `sendEventUpdatedNotification()`
  - **Called In:** [EventsProvider.dart](lib/Providers/EventsProvider.dart) - `updateEvent()` method
  - **Status:** ✅ NOW IMPLEMENTED

#### 5.3 Event Cancelled ✅

- **Trigger:** When admin deletes/cancels an event
- **Recipient:** All assigned volunteers
- **Notification Type:** `Warning`
- **Title:** "Event Cancelled"
- **Message:** "Event '{eventName}' scheduled for {date} has been cancelled."
- **Implementation:**
  - **Helper Method:** `sendEventCancelledNotification()`
  - **Called In:** [EventsProvider.dart](lib/Providers/EventsProvider.dart) - `deleteEvent()` method
  - **Status:** ✅ NOW IMPLEMENTED

---

### 6. Team Management Notifications ✅ NEW

#### 6.1 Added to Team ✅

- **Trigger:** When volunteer is added to a team (creation or update)
- **Recipient:** Volunteer
- **Notification Type:** `Info`
- **Title:** "Team Assignment"
- **Message:** "You have been added to team '{teamName}'"
- **Implementation:**
  - **Helper Method:** `sendAddedToTeamNotification()`
  - **Called In:** [TeamsProvider.dart](lib/Providers/TeamsProvider.dart) - `createTeam()` and `updateTeam()` methods
  - **Status:** ✅ NOW IMPLEMENTED

#### 6.2 Removed from Team ✅

- **Trigger:** When volunteer is removed from a team
- **Recipient:** Volunteer
- **Notification Type:** `Info`
- **Title:** "Team Update"
- **Message:** "You have been removed from team '{teamName}'"
- **Implementation:**
  - **Helper Method:** `sendRemovedFromTeamNotification()`
  - **Called In:** [TeamsProvider.dart](lib/Providers/TeamsProvider.dart) - `updateTeam()` method
  - **Status:** ✅ NOW IMPLEMENTED

#### 6.3 Team Leader Changed ✅

- **Trigger:** When team's leader changes
- **Recipient:** All team members
- **Notification Type:** `Info`
- **Title:** "New Team Leader"
- **Message:** "{leaderName} is now your team leader for '{teamName}'"
- **Implementation:**
  - **Helper Method:** `sendTeamLeaderChangedNotification()`
  - **Called In:** [TeamsProvider.dart](lib/Providers/TeamsProvider.dart) - `updateTeam()` method
  - **Status:** ✅ NOW IMPLEMENTED

---

### 7. Manual Notifications (Not Automatic)

#### Admin Broadcast Notifications

- **Screen:** [SendNotificationScreen.dart](lib/UI/AdminScreens/SendNotificationScreen.dart)
- **Functionality:** Admin can manually send custom notifications to:
  - Individual users
  - Teams (all members)
  - Team leaders only
  - Team members only
  - All volunteers
  - All team leaders
  - All users
- **These are NOT automatic** - admin triggers them manually

---

## ⚠️ Notification Methods Defined But NOT Used Automatically

### 1. Presence Check Reminder

- **Helper Method:** `sendPresenceCheckReminder()`
- **Purpose:** Notify volunteers when presence check (departure/arrival) is starting
- **Parameters:** List of volunteer IDs, event name, check type (Departure/Arrival)
- **Status:** Defined but never called
- **Recommendation:** Call this when admin/team leader initiates presence check

---

## ❌ Missing Automatic Notifications (Recommended)

### 1. Form Status Notifications

#### 1.1 Form Approved

- **Trigger:** When admin approves volunteer registration form (Approved1 or Approved2)
- **Recipient:** Volunteer
- **Suggested Title:** "Registration Approved"
- **Suggested Message:** "Congratulations! Your volunteer registration has been approved. You can now log in with your phone number."
- **Current Status:** Form approval happens in [FormMgmt.dart](lib/UI/AdminScreens/FormMgmt.dart) (Line ~527) but NO notification sent
- **Priority:** HIGH - Volunteers need to know they can log in

#### 1.2 Form Rejected

- **Trigger:** When admin rejects volunteer registration form (Rejected1 or Rejected2)
- **Recipient:** Volunteer
- **Suggested Title:** "Registration Status Update"
- **Suggested Message:** "Your volunteer registration requires additional review. Please contact the administrator."
- **Current Status:** Not implemented
- **Priority:** MEDIUM - Good for transparency

---

### 2. Event-Related Notifications

#### 2.1 New Event Created

- **Trigger:** When new event is created that affects their team
- **Recipient:** Team Leaders and/or team members
- **Suggested Title:** "New Event Created"
- **Suggested Message:** "A new event '{eventName}' has been scheduled for {date}"
- **Priority:** MEDIUM

#### 2.2 Event Updated

- **Trigger:** When event details change (time, location, etc.)
- **Recipient:** All assigned volunteers and team leaders
- **Suggested Title:** "Event Updated"
- **Suggested Message:** "Event '{eventName}' has been updated. Please review the new details."
- **Priority:** HIGH - Important for coordination

#### 2.3 Event Cancelled

- **Trigger:** When event is cancelled
- **Recipient:** All assigned volunteers and team leaders
- **Suggested Title:** "Event Cancelled"
- **Suggested Message:** "Event '{eventName}' scheduled for {date} has been cancelled."
- **Priority:** HIGH - Critical communication

#### 2.4 Event Reminder (24h Before)

- **Trigger:** Automated 24 hours before event start
- **Recipient:** All assigned volunteers
- **Suggested Title:** "Event Reminder"
- **Suggested Message:** "Reminder: You have a shift for '{eventName}' tomorrow at {time}"
- **Priority:** HIGH - Helps with attendance
- **Note:** Requires scheduled job or Cloud Function

---

### 3. Attendance-Related Notifications

#### 3.1 Presence Check Started

- **Trigger:** When admin/team leader initiates departure or arrival check
- **Recipient:** All assigned volunteers for that shift
- **Suggested Title:** "Presence Check Started"
- **Suggested Message:** "{checkType} presence check has started for '{eventName}'. Please check in."
- **Current Status:** Helper method exists (`sendPresenceCheckReminder`) but not called
- **Priority:** HIGH - Improves attendance tracking

#### 3.2 Missed Check-In Alert

- **Trigger:** When volunteer doesn't check in within X minutes of shift start
- **Recipient:** Team Leader
- **Suggested Title:** "Volunteer Missed Check-In"
- **Suggested Message:** "{volunteerName} has not checked in for '{eventName}' shift"
- **Priority:** MEDIUM - Helps team leaders manage attendance

---

### 4. Team-Related Notifications

#### 4.1 Added to Team

- **Trigger:** When volunteer is added to a team
- **Recipient:** Volunteer
- **Suggested Title:** "Team Assignment"
- **Suggested Message:** "You have been added to team '{teamName}'"
- **Priority:** LOW

#### 4.2 Removed from Team

- **Trigger:** When volunteer is removed from a team
- **Recipient:** Volunteer
- **Suggested Title:** "Team Update"
- **Suggested Message:** "You have been removed from team '{teamName}'"
- **Priority:** LOW

#### 4.3 Team Leader Changed

- **Trigger:** When team's leader changes
- **Recipient:** All team members
- **Suggested Title:** "New Team Leader"
- **Suggested Message:** "{leaderName} is now your team leader"
- **Priority:** LOW

---

### 5. Rating/Feedback Notifications

#### 5.1 Volunteer Rated by Admin

- **Trigger:** When admin rates volunteer after event
- **Recipient:** Volunteer
- **Suggested Title:** "Performance Rating Received"
- **Suggested Message:** "You have received a performance rating for '{eventName}'"
- **Priority:** MEDIUM - When rating system is implemented

#### 5.2 Feedback Request

- **Trigger:** After event completion
- **Recipient:** Volunteers who attended
- **Suggested Title:** "Event Feedback Requested"
- **Suggested Message:** "Please share your feedback about '{eventName}'"
- **Priority:** MEDIUM - When feedback system is implemented

---

## 📊 Summary Statistics

### Implemented Automatic Notifications: 13 ✅

1. ✅ Volunteer Shift Assignment
2. ✅ Team Leader Event Assignment **NEWLY WIRED**
3. ✅ Leave Request Submitted
4. ✅ Leave Request Approved
5. ✅ Leave Request Rejected
6. ✅ Location Reassignment
7. ✅ Form Approved **NEW**
8. ✅ Form Rejected **NEW**
9. ✅ New Event Created **NEW**
10. ✅ Event Updated **NEW**
11. ✅ Event Cancelled **NEW**
12. ✅ Added to Team **NEW**
13. ✅ Removed from Team **NEW**
14. ✅ Team Leader Changed **NEW**

### Helper Methods Available But Not Wired: 1

1. ⚠️ Presence Check Reminder - Method exists, optional UI integration needed

### Not Implemented (Low Priority): 3

1. ❌ Event Reminder (24h before) - Requires Cloud Function/scheduled task
2. ❌ Missed Check-In Alert - Requires scheduled monitoring
3. ❌ Rating/Feedback Notifications - Waiting for rating/feedback system

### Implementation Progress

- **Total Planned**: 17 notifications
- **Implemented**: 13 (76%)
- **Available But Not Wired**: 1 (6%)
- **Future Features**: 3 (18%)

---

## 🔧 Implementation Guide

### How to Add New Automatic Notification

#### Step 1: Add Helper Method to NotificationHelperFirebase

```dart
void sendNewNotification(String userId, String param1, String param2) async {
  Notification notification = Notification(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: 'Notification Title',
    message: 'Your message with $param1 and $param2',
    dateTime: DateTime.now(),
    isRead: false,
    type: NotificationType.Info, // Choose: Info, Alert, Warning, Reminder
  );
  createNotification(notification, userId);
}
```

#### Step 2: Call Method at Trigger Point

In the screen/helper where the action happens:

```dart
final notifHelper = NotificationHelperFirebase();
notifHelper.sendNewNotification(userId, param1, param2);
```

#### Step 3: Add Localization (Optional)

If notification text needs translation, add to `lib/l10n/intl_*.arb` files.

---

## 🔔 Notification Types

```dart
enum NotificationType {
  Info,      // General information (blue)
  Alert,     // Important alerts (orange)
  Warning,   // Warnings/rejections (red)
  Reminder,  // Reminders (purple)
}
```

### Usage Guidelines:

- **Info:** Confirmations, approvals, general updates
- **Alert:** Urgent actions, assignments, critical changes
- **Warning:** Rejections, issues, problems
- **Reminder:** Upcoming events, pending actions

---

## 🚀 Implementation Status

### ✅ COMPLETED (December 31, 2025)

**All Priority 1-3 notifications have been implemented!**

- ✅ Form Approved/Rejected Notifications
- ✅ Team Leader Event Assignment  
- ✅ Event Created/Updated/Cancelled Notifications
- ✅ Team Management Notifications (Add/Remove/Leader Change)

### ⚠️ Optional Enhancements

1. **Presence Check Reminder** - Helper method exists, can add optional "Send Reminder" button to presence check screens
2. **Event Reminder (24h before)** - Requires Cloud Function/scheduled task (future enhancement)
3. **Missed Check-In Alert** - Requires scheduled monitoring system (future enhancement)

### 📊 Final Statistics

- **Total Notifications Planned**: 17
- **Implemented**: 13 (76%)
- **Available for Optional Use**: 1 (6%)
- **Future Enhancements**: 3 (18%)

---

## 📝 Notes

- All notifications are stored in Firebase Realtime Database: `/ihs/systemusers/{userPhone}/notifications/{notificationId}`
- Browser notifications require FCM web configuration (already set up - see Bug #8 in BUGS.md)
- Volunteers receive notifications in their dashboard notification center
- Notifications can be marked as read/unread
- Notifications can be deleted by users

---

## 🔗 Related Files

- **Helper:** [NotificationHelperFirebase.dart](lib/Helpers/NotificationHelperFirebase.dart)
- **Model:** [Notification.dart](lib/Models/Notification.dart)
- **Provider:** [NotificationsProvider.dart](lib/Providers/NotificationsProvider.dart)
- **Permission Helper:** [NotificationPermissionHelper.dart](lib/Helpers/NotificationPermissionHelper.dart)
- **Admin Send Screen:** [SendNotificationScreen.dart](lib/UI/AdminScreens/SendNotificationScreen.dart)

---

**For questions or to implement new notifications, refer to the Implementation Guide section above.**
