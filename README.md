# Volunteer Management System (VMS)

A comprehensive Flutter-based system for managing volunteer registrations, events, and teams for the Imam Hussein Shrine (IHS).

## 📋 Table of Contents

1. [Business Models](#business-models)
2. [Technical Capabilities](#technical-capabilities)
3. [Current Project State](#current-project-state)
4. [Setup Instructions](#setup-instructions)
5. [User Manual](#user-manual)
6. [API Documentation](#api-documentation)
7. [Troubleshooting](#troubleshooting)

---

## Business Models

The system is built around several core data models that define the business logic:

### 1. VolunteerForm

The primary model representing a volunteer's registration application.

- **Key Fields**: `fullName`, `mobileNumber` (Unique Key), `formNumber`, `status`.
- **Personal Info**: `birthDate`, `maritalStatus`, `numberOfChildren`, `motherName`.
- **Contact Info**: `currentAddress`, `nearestLandmark`, `mukhtarName`.
- **Professional Info**: `profession`, `jobTitle`, `departmentName`, `politicalAffiliation`.
- **Documents**: `idCardNumber`, `rationCardNumber`, `residenceCardNumber`.
- **Images**:
  - `photoPath`: Personal photo
  - `idFrontPath` / `idBackPath`: National ID
  - `residenceFrontPath` / `residenceBackPath`: Residence Card
- **Status Enum**: `Sent`, `Pending`, `Approved1`, `Rejected1`, `Approved2`, `Rejected2`, `Completed`.

### 2. Event

Represents volunteer events or campaigns.

- **Fields**: `id`, `title`, `description`, `startDate`, `endDate`, `locationId`.

### 3. Location

Physical locations where events take place.

- **Fields**: `id`, `name`, `latitude`, `longitude`, `address`.
- **Sub-Locations**: Optional nested locations for large venues.

### 4. Team

Groups of volunteers organized for specific tasks.

- **Fields**: `id`, `name`, `teamLeaderId`, `memberIds` (List of Phone Numbers).
- **Team Leader**: Reference to SystemUser who manages the team.

### 5. SystemUser

Users who manage and use the system.

- **Fields**: `phone` (Unique Key), `name`, `role` (ADMIN, TEAMLEADER, VOLUNTEER).
- **Authentication**: Firebase Auth using phone number as email (`{phone}@azimuth_vms.com`).

### 6. ShiftAssignment

Assigns volunteers to specific event shifts.

- **Fields**: `id`, `volunteerId`, `shiftId`, `eventId`, `sublocationId` (optional), `status`, `assignedBy`, `timestamp`.
- **Status Enum**: `ASSIGNED`, `EXCUSED`, `COMPLETED`.
- **Firebase Path**: `/ihs/events/{eventId}/assignments/{assignmentId}`.

### 7. LeaveRequest

Handles volunteer absence requests.

- **Fields**: `id`, `volunteerId`, `shiftId`, `eventId`, `reason`, `status`, `requestedAt`, `reviewedBy`, `reviewedAt`.
- **Status Enum**: `PENDING`, `APPROVED`, `REJECTED`.
- **Firebase Path**: `/ihs/events/{eventId}/leave-requests/{requestId}`.

### 8. AttendanceRecord

Tracks two-stage presence verification.

- **Fields**: `id`, `userId`, `eventId`, `shiftId`, `checkType`, `timestamp`, `checkedBy`, `present`.
- **CheckType Enum**: `DEPARTURE`, `ARRIVAL`.
- **Firebase Path**: `/ihs/events/{eventId}/attendance/{userId}/checks/{checkId}`.

### 9. Event (Enhanced)

Extended event model with shift management and presence permissions.

- **New Fields**:
  - `presenceCheckPermissions`: Controls who can check attendance (ADMIN_ONLY, TEAMLEADER_ONLY, BOTH).
  - `shifts`: List of EventShift objects defining time slots and team assignments.
- **EventShift**: Contains `id`, `startTime`, `endTime`, `locationId`, `teamId`, `tempTeam`, `subLocations`.
- **TempTeam**: Inline team with `teamLeaderId` and `memberIds` for one-time teams.

---

## Technical Capabilities

### Core Framework

- **Flutter Web**: Optimized for web deployment using Material Design 3.
- **State Management**: Provider pattern for efficient state handling.

### Backend & Data

- **Firebase Realtime Database**: Stores all application data in a JSON tree structure.
- **Firebase Storage**: Securely stores volunteer documents and images.
- **Authentication**: Firebase Auth (Email/Password).

### Key Features

- **Dynamic Form Generation**: PDF generation using `syncfusion_flutter_pdf`.
- **Image Handling**: Web-based image picking and uploading to Firebase Storage.
- **Maps Integration**: Google Maps for location selection and visualization.
- **Search & Filter**: Real-time filtering of volunteer lists by name, phone, and status.
- **Event Management**: Complete workflow from event creation to presence verification.
- **Shift Assignment**: Flexible volunteer-to-shift mapping with sublocation support.
- **Leave Management**: Digital leave request submission and approval workflow.
- **Two-Stage Presence Checks**: Departure (on bus) and Arrival (at location) verification.
- **Real-Time Notifications**: Browser push notifications via Firebase Cloud Messaging.
- **Role-Based Access Control**: Three-tier system (Admin, Team Leader, Volunteer).

---

## Current Project State

### ✅ Implemented Features

- **Volunteer Registration System**:

  - Multi-step form with 5 sections (Basic Info, Contact, Professional, Documents, Attachments).
  - Image upload integration with Firebase Storage.
  - PDF generation and download/print.
  - Status workflow: Sent → Pending → Approved1/Rejected1 → Approved2/Rejected2 → Completed.

- **Form Management Dashboard**:

  - List view of all volunteer forms.
  - Real-time search by name or phone number.
  - Status filtering.
  - Visual document status indicators.
  - Quick status updates via dropdown.

- **Event Management Workflow**:

  - **Step 1 - Admin Creates Events**: Create events with multiple shifts, assign locations, set dates.
  - **Step 2 - Admin Assigns Teams**: Assign permanent teams or create temporary teams for each shift.
  - **Step 3 - Admin Assigns Volunteers**: Use Shift Assignment Screen to assign specific volunteers to shifts with optional sublocation assignment.
  - **Step 4 - Team Leaders Assign Members**: Team leaders can assign their team members to their assigned shifts via Team Leader Shift Management Screen.
  - **Step 5 - Volunteers View Events**: Volunteers see their assigned events with shift times, locations, and team leader contact info on My Events screen.
  - **Step 6 - Leave Request Flow**:
    - Volunteers submit leave requests per shift with detailed reason.
    - Team leaders review pending requests in Leave Request Management Screen.
    - Approval changes shift assignment status to EXCUSED.
    - Volunteers receive real-time notifications of approval/rejection.
  - **Step 7 - Two-Stage Presence Checks**:
    - **Departure Check**: Admin/Team Leader marks volunteers present/absent when boarding bus.
    - **Arrival Check**: Admin/Team Leader marks volunteers present/absent upon arrival at location.
    - Real-time statistics display (Present/Absent/Not Checked/Excused counts).
    - Permission system controls who can perform checks (ADMIN_ONLY, TEAMLEADER_ONLY, BOTH).

- **Real-Time Features**:

  - Live updates via Firebase Realtime Database listeners.
  - Browser push notifications using Firebase Cloud Messaging (FCM).
  - Real-time presence check updates across all connected devices.

- **Firebase Integration**:
  - Full CRUD operations for all models.
  - Nested data structure under events for assignments, leave requests, and attendance.
  - Image storage structure: `ihs/volunteerForms/{phoneNumber}/{imageName}`.

### 🚧 Pending / In Progress

- Advanced reporting and analytics.
- Volunteer rating system implementation.
- Export functionality for attendance reports.

---

## Setup Instructions

### Prerequisites

- Flutter SDK (3.x or higher)
- Chrome browser (for web debugging)
- Firebase Project with Realtime Database and Storage enabled

### 1. Clone & Install

```bash
git clone <repository-url>
cd azimuth_vms
flutter pub get
```

### 2. Firebase Configuration

1. Ensure `firebase_options.dart` is present in `lib/`.
2. If missing, run:
   ```bash
   flutterfire configure
   ```

### 3. Google Maps Setup

1. Get a Google Maps API Key.
2. Enable **Maps JavaScript API** in Google Cloud Console.
3. Enable billing for your Google Cloud project.
4. Add the key to `web/index.html`:
   ```html
   <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
   ```

### 4. Firebase Cloud Messaging (FCM) Setup

1. **Get VAPID Key**:

   - Go to Firebase Console > Project Settings > Cloud Messaging.
   - Under "Web configuration", generate a Web Push certificate.
   - Copy the VAPID key.

2. **Update Service Worker**:

   - Open `web/firebase-messaging-sw.js`.
   - Replace the Firebase configuration object with your project's config.

3. **Update Helper**:

   - Open `lib/Helpers/NotificationPermissionHelper.dart`.
   - Replace `YOUR_VAPID_KEY_HERE` with your actual VAPID key in the `getToken()` method.

4. **Request Permissions**:
   - Browser notification permission is requested automatically when users sign in.
   - Users must allow notifications in their browser for real-time alerts.

### 5. Run the App

```bash
flutter run -d chrome
```

---

## User Manual

### Admin Users

#### Managing Events

1. **Create Event**: Dashboard > Events > Click "+" button.
2. **Add Shifts**: Define time slots, assign locations, choose team assignment type.
3. **Set Permissions**: Choose who can perform presence checks (Admin Only / Team Leader Only / Both).

#### Assigning Volunteers to Shifts

1. **Navigate**: Dashboard > Shift Assignment.
2. **Select Event**: Choose from dropdown.
3. **Select Shift**: Choose the time slot.
4. **Assign Volunteers**: Click "Select Volunteers" button.
5. **Optional Sublocation**: Use "Reassign Location" to move volunteers to specific sublocations.
6. **Notification**: Volunteers are automatically notified via browser notification.

#### Performing Presence Checks

1. **Navigate**: Dashboard > Presence Checks.
2. **Select Event**: Choose from dropdown.
3. **Select Shift**: Choose the time slot.
4. **Choose Tab**:
   - **Departure**: Check volunteers as they board the bus.
   - **Arrival**: Check volunteers as they arrive at the location.
5. **Mark Attendance**: Click checkmark (present) or X (absent) for each volunteer.
6. **View Statistics**: See real-time counts at the top (Present/Absent/Not Checked/Excused).

### Team Leader Users

#### Managing Team Shifts

1. **Navigate**: Dashboard > Manage Shifts.
2. **Select Event**: Expand event to see your assigned shifts.
3. **Assign Members**: Select shift and choose volunteers from your team.
4. **Notification**: Assigned volunteers receive browser notifications.

#### Reviewing Leave Requests

1. **Navigate**: Dashboard > Leave Requests.
2. **Select Event**: View pending leave requests for your team.
3. **Review Reason**: Read the volunteer's leave explanation.
4. **Approve/Reject**:
   - **Approve**: Changes shift assignment status to EXCUSED.
   - **Reject**: Leave request status updates, assignment remains ASSIGNED.
5. **Notification**: Volunteer receives immediate notification of decision.

#### Checking Attendance

1. **Navigate**: Dashboard > Presence Checks.
2. **Follow same process as Admin** (if permission granted).
3. **Scope**: Can only check volunteers assigned to your teams.

### Volunteer Users

#### Viewing Assigned Events

1. **Navigate**: Dashboard > My Events.
2. **View Details**:
   - Event name and date.
   - Shift time.
   - Assigned location/sublocation.
   - Team leader name and phone.
3. **View on Map**: Click "View on Map" to see location in Google Maps.

#### Requesting Leave

1. **From Event Card**: Click "Request Leave" button.
2. **Provide Reason**: Enter detailed explanation (minimum 10 characters).
3. **Submit**: Request goes to team leader for review.
4. **Track Status**: Check notification for approval/rejection.
5. **Timing**: Can request leave even after event has started.

### Managing Volunteer Forms

1. **Navigate to Forms**: Click on the "Forms" tab in the main dashboard.
2. **Search**: Use the search bar at the top to find a volunteer by name or phone.
3. **Filter**: Use the dropdown on the top right to filter by status (e.g., "Sent", "Approved").
4. **Check Documents**: Look at the chips on each card. Green means the document is uploaded; Red means it's missing.
5. **Change Status**: Use the dropdown on the card to change the application status.

### Creating/Editing a Form

1. **Create New**: Click the `+` button on the Forms page.
2. **Edit Existing**: Tap on any volunteer card in the list.
3. **Fill Details**: Complete the 5-step form.
4. **Upload Images**: In the "Attachments" step, upload the required photos.
   - _Note: If editing, existing images will be shown with a "Saved" indicator._
5. **Save**: Click the Save icon in the top right. This will upload images and save data to Firebase.
6. **Print/Download**: Use the Print or Download icons to generate a PDF version of the form.

---

## API Documentation

### Firebase Database Structure

Root Node: `ihs`

#### `/ihs/forms/{mobileNumber}`

Stores volunteer form data.

```json
{
  "fullName": "Ahmed Saad",
  "mobileNumber": "07701234567",
  "status": "Sent",
  "photoPath": "https://firebasestorage.googleapis.com/...",
  "idFrontPath": "https://firebasestorage.googleapis.com/...",
  ...
}
```

#### `/ihs/events/{eventId}/`

Stores event data with nested collections:

```json
{
  "id": "event123",
  "name": "Arbaeen Service",
  "startDate": "2025-01-15",
  "endDate": "2025-01-20",
  "presenceCheckPermissions": "BOTH",
  "shifts": [...],
  "assignments": {
    "assign123": {
      "id": "assign123",
      "volunteerId": "07701234567",
      "shiftId": "shift1",
      "eventId": "event123",
      "status": "ASSIGNED",
      "sublocationId": "subloc1",
      "assignedBy": "admin001",
      "timestamp": "2025-01-10T10:30:00Z"
    }
  },
  "leave-requests": {
    "req123": {
      "id": "req123",
      "volunteerId": "07701234567",
      "shiftId": "shift1",
      "eventId": "event123",
      "reason": "Medical emergency",
      "status": "PENDING",
      "requestedAt": "2025-01-14T08:00:00Z"
    }
  },
  "attendance": {
    "07701234567": {
      "checks": {
        "check1": {
          "id": "check1",
          "userId": "07701234567",
          "eventId": "event123",
          "shiftId": "shift1",
          "checkType": "DEPARTURE",
          "timestamp": "2025-01-15T06:00:00Z",
          "checkedBy": "teamleader001",
          "present": true
        }
      }
    }
  }
}
```

#### `/ihs/notifications/{userPhone}/`

Stores user notifications:

```json
{
  "notif123": {
    "id": "notif123",
    "title": "Shift Assignment",
    "body": "You have been assigned to Arbaeen Service shift",
    "timestamp": "2025-01-10T10:30:00Z",
    "read": false
  }
}
```

### Firebase Storage Structure

#### `/ihs/volunteerForms/{mobileNumber}/`

- `photo.jpg`: Personal photo
- `id_front.jpg`: National ID Front
- `id_back.jpg`: National ID Back
- `residence_front.jpg`: Residence Card Front
- `residence_back.jpg`: Residence Card Back

### Helper Classes

#### Volunteer Forms

- **`VolunteerFormHelperFirebase`**:
  - `CreateForm(VolunteerForm form)`: Creates a new record.
  - `UpdateForm(VolunteerForm form)`: Updates existing record.
  - `GetAllForms()`: Returns `List<VolunteerForm>`.
  - `GetFormByMobileNumber(String mobile)`: Returns single `VolunteerForm`.

#### Shift Assignments

- **`ShiftAssignmentHelperFirebase`**:
  - `CreateShiftAssignment(ShiftAssignment assignment)`: Creates new assignment.
  - `GetShiftAssignmentsByEvent(String eventId)`: Returns all assignments for an event.
  - `GetShiftAssignmentsByVolunteer(String volunteerId)`: Returns volunteer's assignments.
  - `StreamShiftAssignmentsByEvent(String eventId)`: Real-time stream of assignments.
  - `UpdateShiftAssignment(ShiftAssignment assignment)`: Updates assignment status.

#### Leave Requests

- **`LeaveRequestHelperFirebase`**:
  - `CreateLeaveRequest(LeaveRequest request)`: Creates new leave request.
  - `GetLeaveRequestsByEvent(String eventId)`: Returns all leave requests for an event.
  - `StreamPendingLeaveRequests(String eventId)`: Real-time stream of pending requests.
  - `UpdateLeaveRequest(LeaveRequest request)`: Updates request status.

#### Attendance

- **`AttendanceHelperFirebase`**:
  - `CreateAttendanceRecord(AttendanceRecord record)`: Creates attendance check.
  - `GetAttendanceByEventAndShift(String eventId, String shiftId)`: Returns all checks.
  - `StreamAttendanceByEventAndShift(String eventId, String shiftId)`: Real-time stream.
  - `UpdateAttendanceRecord(AttendanceRecord record)`: Updates attendance.

#### Notifications

- **`NotificationHelperFirebase`**:

  - `sendShiftAssignmentNotificationToTeamLeader(...)`: Notifies team leader of assignment.
  - `sendVolunteerAssignmentNotification(...)`: Notifies volunteer of shift assignment.
  - `sendLeaveRequestNotificationToTeamLeader(...)`: Notifies team leader of leave request.
  - `sendLeaveApprovedNotification(...)`: Notifies volunteer of approval.
  - `sendLeaveRejectedNotification(...)`: Notifies volunteer of rejection.
  - `sendLocationReassignmentNotification(...)`: Notifies volunteer of location change.

- **`NotificationPermissionHelper`** (Web-only):
  - `requestPermission()`: Requests browser notification permission.
  - `getToken(vapidKey)`: Gets FCM device token.
  - `setupForegroundMessageHandler()`: Handles foreground notifications.
  - `handleBackgroundMessage()`: Background message handler.

---

## Troubleshooting

### Common Issues

#### 1. Images not uploading

- **Cause**: Firebase Storage rules might be blocking the write.
- **Solution**: Check Firebase Console > Storage > Rules. Ensure write access is allowed for the path `ihs/volunteerForms/{phoneNumber}/*`.

#### 2. "Null check operator used on a null value"

- **Cause**: Trying to access a field that doesn't exist in the database.
- **Solution**: Ensure all required fields are populated before saving. The app handles missing optional fields gracefully, but critical keys like `mobileNumber` must exist.

#### 3. Google Maps not loading

- **Cause**: API Key missing or billing not enabled.
- **Solution**: Check `web/index.html` and ensure the API key is valid and has "Maps JavaScript API" enabled in Google Cloud Console. Billing must be enabled.

#### 4. PDF Text Rendering Issues

- **Cause**: Arabic font support in PDF generation.
- **Solution**: Ensure the font assets are correctly loaded and the `syncfusion_flutter_pdf` package is configured to use a font that supports Arabic characters if you see boxes instead of text.

#### 5. Browser Notifications Not Working

- **Cause**: Multiple possible causes.
- **Solutions**:
  - Check that browser notification permission is granted.
  - Verify VAPID key is correctly set in `NotificationPermissionHelper.dart`.
  - Ensure Firebase config is updated in `web/firebase-messaging-sw.js`.
  - Check browser console for service worker registration errors.
  - Test in Chrome (best FCM support for web).

#### 6. Real-Time Updates Not Appearing

- **Cause**: Provider listeners not properly initialized or disposed.
- **Solutions**:
  - Ensure `startListening...()` methods are called in provider.
  - Check that `stopListening()` is called in `dispose()` to prevent memory leaks.
  - Verify Firebase Realtime Database rules allow read access.
  - Check browser console for Firebase connection errors.

#### 7. Shift Assignment Not Showing for Volunteers

- **Cause**: Assignment data structure mismatch or volunteer ID incorrect.
- **Solutions**:
  - Verify volunteer phone number matches exactly (no spaces, correct format).
  - Check Firebase Console to ensure assignment exists under `/ihs/events/{eventId}/assignments/`.
  - Ensure `volunteerId` in assignment matches volunteer's phone number.

#### 8. Leave Request Not Creating

- **Cause**: Permission issues or network problems.
- **Solutions**:
  - Check browser console for error messages.
  - Verify Firebase Realtime Database rules allow write to `/ihs/events/{eventId}/leave-requests/`.
  - Ensure user is authenticated (check `FirebaseAuth.instance.currentUser`).
  - Validate all required fields are filled (volunteerId, shiftId, eventId, reason).

#### 9. Presence Check Permissions Not Working

- **Cause**: Permission enum not properly saved or read.
- **Solutions**:
  - Check Event object has `presenceCheckPermissions` field set.
  - Verify field serialization in `Event.fromDataSnapshot()`.
  - Default value is `BOTH` if not specified.
  - Check team leader's role in Firebase (must be `TEAMLEADER`).

#### 10. Dependency Conflicts During `flutter pub get`

- **Cause**: Version mismatches between Firebase packages.
- **Solutions**:
  - Run `flutter pub upgrade` to update all packages.
  - If specific conflict, upgrade the conflicting package: `flutter pub add package_name:^latest_version`.
  - Check `pubspec.yaml` for version constraints that might be too restrictive.
  - Clear pub cache: `flutter pub cache repair`.

---

## Event Management Workflow Summary

### Complete Process Flow

1. **Admin Creates Event** → Sets dates, locations, shifts, and team assignments.
2. **Admin Assigns Volunteers** → Uses Shift Assignment Screen to map volunteers to specific shifts.
3. **Team Leaders Refine Assignments** → Team leaders assign their team members to their shifts.
4. **Volunteers View Assignments** → Volunteers see events on "My Events" screen with location maps.
5. **Volunteer Requests Leave** (Optional) → Submit reason, team leader approves/rejects.
6. **Departure Check** → Admin/Team Leader marks attendance as volunteers board bus.
7. **Arrival Check** → Admin/Team Leader marks attendance upon arrival at event location.
8. **Real-Time Notifications** → All participants receive browser notifications for assignments, approvals, and updates.

### Key System Features

- **Nested Firebase Structure**: All event-related data (assignments, leave requests, attendance) stored under event node for efficient querying.
- **Real-Time Listeners**: Provider pattern with `StreamSubscription` for live updates across all screens.
- **Flexible Team System**: Supports both permanent teams and temporary one-time teams.
- **Sublocation Support**: Volunteers can be assigned to specific areas within a location.
- **Two-Stage Verification**: Departure and arrival checks ensure complete attendance tracking.
- **Permission System**: Granular control over who can perform presence checks.
- **Browser Notifications**: Web-based push notifications using FCM service worker.

---

_Last Updated: December 21, 2025_
