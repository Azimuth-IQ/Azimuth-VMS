# Volunteer Management System (VMS)

A comprehensive Flutter-based system for managing volunteer registrations, events, and teams for the Imam Hussein Shrine (IHS).

**🌐 Multi-Language Support**: Fully supports English and Arabic with RTL (Right-to-Left) layout.

## 📋 Table of Contents

1. [Business Models](#business-models)
2. [Technical Capabilities](#technical-capabilities)
3. [Current Project State](#current-project-state)
4. [Multi-Language Support](#multi-language-support)
5. [Setup Instructions](#setup-instructions)
6. [User Manual](#user-manual)
7. [API Documentation](#api-documentation)
8. [Troubleshooting](#troubleshooting)

---

## System Goal & Vision

### Primary Objective

The Volunteer Management System (VMS) for Imam Hussein Shrine (IHS) is designed to streamline the complete lifecycle of volunteer management for religious events and campaigns—from initial registration through event execution and performance evaluation.

### Target Users

- **Admins**: Full system control, manage all users, locations, teams, and events
- **Team Leaders**: Manage their teams, assign volunteers to shifts, check attendance
- **Volunteers**: Fill applications, view assignments, request leaves

### Core Workflows

The system supports eight major operational workflows:

1. Volunteer invitation and registration with approval workflow
2. Event creation with date/time scheduling and recurrence
3. Shift allocation and volunteer assignment
4. Two-stage attendance verification (departure & arrival)
5. Location reassignment during events
6. Urgent leave request management
7. Volunteer performance rating (PARTIALLY IMPLEMENTED)
8. Feedback collection system (NOT IMPLEMENTED)

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

### 8. Event (Enhanced)

Extended event model with shift management and presence permissions.

- **New Fields**:
  - `presenceCheckPermissions`: Controls who can check attendance (ADMIN_ONLY, TEAMLEADER_ONLY, BOTH).
  - `shifts`: List of EventShift objects defining time slots and team assignments.
  - **Recurrence Support**: `isRecurring`, `recurrenceType`, `recurrenceEndDate`.
  - **Recurrence Types**: NONE, DAILY, WEEKLY, MONTHLY, YEARLY.
  - **Recurrence Rules**: `weeklyDays` (comma-separated), `monthlyDay`, `yearlyDay`, `yearlyMonth`.
- **EventShift**: Contains `id`, `startTime`, `endTime`, `locationId`, `teamId`, `tempTeam`, `subLocations`.
- **TempTeam**: Inline team with `teamLeaderId` and `memberIds` for one-time teams.
- **ShiftSubLocation**: Nested location assignments with optional team assignments.

### 9. VolunteerRating

Tracks volunteer performance ratings based on defined criteria.

- **Fields**: `id`, `ratings` (Map of criteria to scores), `Date`, `Time`, `Notes`.
- **Ratings**: Map of VolunteerRatingCriteria to integer scores (1-5).
- **Storage**: Embedded within SystemUser model as `volunteerRating` field.
- **Status**: ⚠️ MODEL DEFINED but NO UI IMPLEMENTATION YET.

### 10. VolunteerRatingCriteria

Defines rating categories for volunteer performance.

- **Fields**: `Criteria` (String name of criterion).
- **Default Criteria** (from model comments):
  1. Adherence to dress code
  2. Adherence to location of event
  3. Adherence to instructions
  4. Presence score
  5. Interaction with visitors
  6. Active cooperation with other employees
  7. Time commitment
- **Status**: ⚠️ MODEL DEFINED but NO HELPER/PROVIDER/UI IMPLEMENTATION.

### 11. Feedback Models

**Status**: ❌ NOT IMPLEMENTED

The system currently has **NO models, helpers, providers, or UI** for the three types of feedback mentioned in requirements:

- Admin rating volunteers and team leaders
- System user feedback on system/bugs
- Volunteer feedback for event management

---

## Technical Capabilities

### Core Framework

- **Flutter Web**: Optimized for web deployment using Material Design 3.
- **State Management**: Provider pattern exclusively (no StatefulWidgets for state).
- **Multi-Language Support**: Full localization for English and Arabic with RTL support.

### Backend & Data

- **Firebase Realtime Database**: Stores all application data in a JSON tree structure.
- **Firebase Storage**: Securely stores volunteer documents and images.
- **Authentication**: Firebase Auth (Email/Password) using phone as email format.

### Key Features

- **Dynamic Form Generation**: PDF generation using `syncfusion_flutter_pdf`.
- **Image Handling**: Web-based image picking and uploading to Firebase Storage.
- **Maps Integration**: Google Maps for location selection and visualization.
- **Search & Filter**: Real-time filtering of volunteer lists by name, phone, and status.
- **Event Management**: Complete workflow from event creation to presence verification.
- **Event Recurrence**: Support for recurring events (daily, weekly, monthly, yearly).
- **Shift Assignment**: Flexible volunteer-to-shift mapping with sublocation support.
- **Leave Management**: Digital leave request submission and approval workflow.
- **Two-Stage Presence Checks**: Departure (on bus) and Arrival (at location) verification.
- **Real-Time Notifications**: Browser push notifications via Firebase Cloud Messaging.
- **Role-Based Access Control**: Three-tier system (Admin, Team Leader, Volunteer).
- **Location Reassignment**: Dynamic volunteer relocation during events with notifications.
- **Language Switching**: Users can switch between English and Arabic in real-time.

---

## Multi-Language Support

### Overview

The application fully supports **English** and **Arabic** languages with proper RTL (Right-to-Left) text direction for Arabic.

### Features

- **Real-time Language Switching**: Users can change language without restarting the app
- **Persistent Language Selection**: Selected language is saved using `SharedPreferences`
- **RTL Support**: Automatic right-to-left layout for Arabic text
- **Comprehensive Translations**: 200+ translation keys covering all UI elements
- **Language Switcher Widget**: Available in all major screens via AppBar

### Implementation Files

- **Translation Files**:
  - [lib/l10n/app_en.arb](lib/l10n/app_en.arb) - English translations
  - [lib/l10n/app_ar.arb](lib/l10n/app_ar.arb) - Arabic translations
- **Provider**: [lib/Providers/LanguageProvider.dart](lib/Providers/LanguageProvider.dart)
- **Widget**: [lib/UI/Widgets/LanguageSwitcher.dart](lib/UI/Widgets/LanguageSwitcher.dart)
- **Configuration**: [l10n.yaml](l10n.yaml)

### Using Localizations in Code

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// In build method:
final l10n = AppLocalizations.of(context)!;

// Use translations:
Text(l10n.dashboard)
Text(l10n.welcomeBack(userPhone))
```

### Adding New Translations

1. Add key-value pair to both `app_en.arb` and `app_ar.arb`
2. Run `flutter pub get` to regenerate localization files
3. Use the key in your code: `l10n.yourNewKey`

**Full Developer Guide**: See [LOCALIZATION_GUIDE.md](LOCALIZATION_GUIDE.md) for detailed implementation instructions.

---

## Current Project State

**Last Updated**: December 31, 2025

**Bug Tracking**: See [BUGS.md](BUGS.md) for detailed bug status (16/19 bugs fixed, 84% completion rate)

### ✅ FULLY IMPLEMENTED Features

#### 1. Admin Setup & Management

- ✅ **System Users Management**: Create/edit admins and team leaders via [TeamLeadersMgmt.dart](lib/UI/AdminScreens/TeamLeadersMgmt.dart)
- ✅ **Locations Management**: Create locations with Google Maps integration, add sublocations via [LocationsMgmt.dart](lib/UI/AdminScreens/LocationsMgmt.dart)
- ✅ **Teams Management**: Create teams, assign team leaders, add members via [TeamsMgmt.dart](lib/UI/AdminScreens/TeamsMgmt.dart)
- ✅ **Theme Settings**: Three fully functional themes (Red/Dark, Green/Light, Gold/Dark) with complete localization
- ✅ **Carousel Management**: Image carousel for announcements across all dashboards

#### 2. Volunteer Registration Workflow (Flow #1)

- ✅ **Invitation Flow**: Admin creates empty form with volunteer's phone number
- ✅ **Volunteer Form Filling**: Multi-step form with 5 sections via [FormFillPage.dart](lib/UI/VolunteerScreens/FormFillPage.dart)
  - Basic Info (name, education, birth date, marital status)
  - Contact Info (address, landmark, mukhtar name)
  - Professional Info (profession, job title, political affiliation, talents)
  - Documents (ID numbers, ration card, residence card)
  - Attachments (photo with formal clothing hint, ID images, residence card images)
- ✅ **Image Upload Integration**: Web-based image picker with Firebase Storage
- ✅ **Bilingual Photo Hint**: Localized hint for formal clothing on white background
- ✅ **Status Workflow**: Sent → Pending → Approved1/Rejected1 → Approved2/Rejected2 → Completed
- ✅ **PDF Generation**: Download/print volunteer forms
- ✅ **Form Management Dashboard**: Search, filter, quick status updates via [FormMgmt.dart](lib/UI/AdminScreens/FormMgmt.dart)
- ✅ **Approval/Rejection Notifications**: Automatic notifications when forms are approved or rejected

#### 3. Event Creation Workflow (Flow #2)

- ✅ **Event Creation**: Main info, description via [EventsMgmt.dart](lib/UI/AdminScreens/EventsMgmt.dart)
- ✅ **Date & Time Scheduling**: Start/end dates with time selection
- ✅ **Recurrence Feature**: Daily, Weekly, Monthly, Yearly with custom rules
  - Weekly: Select specific days (Monday, Wednesday, etc.)
  - Monthly: Specify day of month (e.g., 15th)
  - Yearly: Specify day and month (e.g., December 25th)
  - Optional recurrence end date
- ✅ **Multiple Shifts**: Define unlimited shifts per event
- ✅ **Location Assignment**: Assign main location and sublocations per shift
- ✅ **Team Assignment**: Choose existing teams or create temporary teams per shift/sublocation
- ✅ **Presence Check Permissions**: Control who can check attendance (ADMIN_ONLY, TEAMLEADER_ONLY, BOTH)

#### 4. Shift Allocation Workflow (Flow #3)

- ✅ **Admin Assignment Screen**: Assign specific volunteers to shifts via [ShiftAssignmentScreen.dart](lib/UI/AdminScreens/ShiftAssignmentScreen.dart)
- ✅ **Team Leader Assignment**: Team leaders assign their team members via [TeamLeaderShiftManagementScreen.dart](lib/UI/TeamLeadersScreens/TeamLeaderShiftManagementScreen.dart)
- ✅ **Search Functionality**: Real-time search in assignment dialogs by name or phone
- ✅ **Notification System**: Automatic browser notifications for:
  - Team leaders when assigned to manage event
  - Volunteers when assigned to shifts
  - New event created (to team leaders)
  - Event updated (to assigned volunteers)
  - Event cancelled (to assigned volunteers)
  - Team membership changes (add/remove/leader change)
- ✅ **Sublocation Assignment**: Optional assignment to specific sublocations
- ✅ **Real-Time Updates**: All assignments update in real-time via Firebase listeners

#### 5. Event Day Attendance (Flow #4)

- ✅ **Two-Stage Presence Checks** via [PresenceCheckScreen.dart](lib/UI/AdminScreens/PresenceCheckScreen.dart) and [TeamLeaderPresenceCheckScreen.dart](lib/UI/TeamLeadersScreens/TeamLeaderPresenceCheckScreen.dart):
  - **Departure Check**: Mark attendance as volunteers board bus/gather
  - **Arrival Check**: Mark attendance upon arrival at location
- ✅ **Real-Time Statistics**: Live counts (Present/Absent/Not Checked/Excused)
- ✅ **Permission System**: Respects event's presence check permissions setting
- ✅ **Multi-User Support**: Admins and team leaders can check simultaneously

#### 6. Location Reassignment (Flow #5)

- ✅ **Dynamic Reassignment**: Admin can move volunteers between locations/sublocations via [LocationReassignmentDialog.dart](lib/UI/AdminScreens/LocationReassignmentDialog.dart)
- ✅ **Additional Attendance Check**: Take new attendance after reassignment
- ✅ **Volunteer Notification**: Automatic notification of location change

#### 7. Leave Request Management (Flow #6)

- ✅ **Volunteer Leave Request**: Submit urgent leave with detailed reason via [LeaveRequestScreen.dart](lib/UI/VolunteerScreens/LeaveRequestScreen.dart)
- ✅ **Team Leader Review**: View pending requests, approve/reject via [LeaveRequestManagementScreen.dart](lib/UI/TeamLeadersScreens/LeaveRequestManagementScreen.dart)
- ✅ **Status Update**: Approved requests change assignment status to EXCUSED
- ✅ **Real-Time Notifications**:
  - Team leader notified of new leave request
  - Volunteer notified of approval/rejection
- ✅ **Timing Flexibility**: Can request leave before or during event

#### 8. Real-Time Features

- ✅ **Live Updates**: Firebase Realtime Database listeners for all collections
- ✅ **Browser Push Notifications**: FCM-based notifications with service worker (13 automatic notification types)
- ✅ **Notification Permission Handling**: Automatic permission request on sign-in
- ✅ **Background Notifications**: Service worker handles notifications when tab is inactive
- ✅ **Notification Coverage**: 76% of planned notifications implemented (see [AUTOMATIC_NOTIFICATIONS.md](AUTOMATIC_NOTIFICATIONS.md))

#### 9. Volunteer Dashboard

- ✅ **My Events View**: See all assigned events via [VolunteerEventDetailsScreen.dart](lib/UI/VolunteerScreens/VolunteerEventDetailsScreen.dart)
- ✅ **My Schedule Access**: Navigate to schedule from both desktop and mobile views
- ✅ **Event Details Display**:
  - Event name and date
  - Shift time (start - end)
  - Location/sublocation information (by name, not ID)
  - Team leader name and phone (not phone number)
  - Assigned by admin/team leader name
- ✅ **Google Maps Integration**: View location on map
- ✅ **Leave Request Button**: Quick access to leave request form
- ✅ **Image Carousel**: Announcements and updates displayed on dashboard

#### 10. Localization & UI

- ✅ **Complete Bilingual Support**: All UI elements in English and Arabic
- ✅ **RTL Layout**: Proper right-to-left layout for Arabic
- ✅ **Language Switcher**: Real-time language switching on all screens
- ✅ **Mobile Responsive**: Optimized font sizes and layouts for mobile devices
- ✅ **Theme Settings Localization**: All theme-related text fully translated
- ✅ **Search Dialogs**: Localized search functionality across all selection dialogs

#### 11. Recent Fixes & Improvements (December 2025)

- ✅ **Bug #4**: Added bilingual photo upload hint (formal clothing on white background)
- ✅ **Bug #7**: Implemented 13 automatic notifications (76% coverage) - see [AUTOMATIC_NOTIFICATIONS.md](AUTOMATIC_NOTIFICATIONS.md)
- ✅ **Bug #14**: Fixed carousel slider inconsistency across all dashboards
- ✅ **Bug #16**: Complete theme settings localization (English/Arabic)
- ✅ **Technical Debt**: Removed unused google_fonts package and extra PDF templates
- ✅ **Display Fixes**: Location/sublocation names shown instead of IDs
- ✅ **Display Fixes**: Assigner names shown instead of phone numbers
- ✅ **Mobile Optimization**: Font sizes adjusted for mobile devices
- ✅ **Navigation Fix**: Theme settings clickable on desktop view

---

### ⚠️ PARTIALLY IMPLEMENTED Features

#### Volunteer Rating System (Flow #7 - INCOMPLETE)

- ✅ **Data Models**: `VolunteerRating` and `VolunteerRatingCriteria` exist in [lib/Models/](lib/Models/)
- ✅ **Model Integration**: `volunteerRating` field in `SystemUser` model
- ❌ **No Helper Class**: No `VolunteerRatingHelperFirebase` for CRUD operations
- ❌ **No Provider**: No state management provider for ratings
- ❌ **No UI Screens**: No interface for admins to rate volunteers
- ❌ **No Score Calculation**: No automatic score calculation based on attendance/feedback
- ❌ **No Score Display**: Ratings not visible anywhere in admin dashboard
- ❌ **No Rating Criteria Management**: No UI to configure rating criteria

**Rating Criteria Defined in Model**:

1. Adherence to dress code
2. Adherence to location of event
3. Adherence to instructions
4. Presence score
5. Interaction with visitors
6. Active cooperation with other employees
7. Time commitment

---

### ❌ NOT IMPLEMENTED Features

#### Feedback System (Flow #8 - COMPLETELY MISSING)

The system has **NO implementation** for any of the three feedback types:

##### A. Admin Rating Volunteers/Team Leaders

- ❌ No feedback model for admin ratings
- ❌ No UI for admins to rate volunteers after events
- ❌ No UI for admins to rate team leaders
- ❌ No feedback history tracking
- ❌ Not integrated with volunteer rating system

##### B. System User Feedback (Bugs/Improvements)

- ❌ No model for system feedback
- ❌ No feedback submission form
- ❌ No feedback categories (bug report, feature request, improvement)
- ❌ No admin dashboard to view feedback
- ❌ No feedback status tracking (pending, in-progress, resolved)
- ❌ No attachment support for bug screenshots

##### C. Volunteer Event Feedback

- ❌ No model for event feedback
- ❌ No volunteer feedback form for events
- ❌ No feedback submission after event completion
- ❌ No admin view of volunteer event feedback
- ❌ No feedback categorization (organization, logistics, management issues)
- ❌ No feedback aggregation/reporting

#### Advanced Reporting & Analytics

- ❌ No attendance reports export (CSV/PDF)
- ❌ No volunteer performance analytics dashboard
- ❌ No event statistics summary
- ❌ No team performance metrics
- ❌ No leave request statistics
- ❌ No location utilization reports

#### Additional Missing Features

- ❌ No volunteer availability management (volunteers set their available dates/times)
- ❌ No conflict detection (double-booking volunteers)
- ❌ No event templates (save common event configurations)
- ❌ No bulk operations (assign multiple volunteers at once - currently manual)
- ❌ No email notifications (only browser push notifications)
- ❌ No SMS notifications
- ❌ No volunteer badges/achievements system
- ❌ No volunteer certificate generation
- ❌ No volunteer hour tracking
- ❌ No admin activity logs (audit trail)

---

### 🔧 Current Technical State

#### Working Components

- ✅ All models properly defined with DataSnapshot parsing
- ✅ All helpers implement CRUD and streaming operations
- ✅ All providers use ChangeNotifier pattern correctly
- ✅ Firebase Storage properly configured for image uploads
- ✅ Google Maps API integrated and working
- ✅ FCM notifications working with service worker
- ✅ Authentication flow complete
- ✅ Role-based routing functional

#### Known Limitations

- ⚠️ Web-only (no mobile app support yet)
- ⚠️ Chrome browser recommended (best FCM support)
- ⚠️ Google Maps API requires billing enabled
- ⚠️ No offline support
- ⚠️ No data export functionality
- ⚠️ No automated testing implemented

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

## 📋 Development Roadmap & TODO

### Priority 1: Complete Core Workflows (High Priority)

#### 1.1 Volunteer Rating System (Flow #7)

**Goal**: Allow admins to rate volunteers based on performance criteria

- [ ] Create `VolunteerRatingHelperFirebase` in [lib/Helpers/](lib/Helpers/)
  - [ ] `CreateRating(String volunteerId, VolunteerRating rating)`
  - [ ] `UpdateRating(String volunteerId, VolunteerRating rating)`
  - [ ] `GetRatingByVolunteer(String volunteerId)`
  - [ ] `GetAllRatings()` for analytics
- [ ] Create `VolunteerRatingProvider` in [lib/Providers/](lib/Providers/)
  - [ ] State management for rating forms
  - [ ] Calculate average scores per criterion
  - [ ] Track rating history
- [ ] Create `VolunteerRatingScreen.dart` in [lib/UI/AdminScreens/](lib/UI/AdminScreens/)
  - [ ] Display volunteer list with current scores
  - [ ] Rating form with 1-5 stars per criterion
  - [ ] Notes field for feedback
  - [ ] Date/time stamp
  - [ ] Save and view rating history
- [ ] Create `RatingCriteriaManagementScreen.dart`
  - [ ] Allow admins to configure criteria list
  - [ ] Add/remove/edit criteria
  - [ ] Set criteria weights
- [ ] **Auto-Calculate Scores**:
  - [ ] Presence score based on attendance records
  - [ ] Deduct points for absences
  - [ ] Deduct points for rejected leave requests
  - [ ] Add points for good feedback
- [ ] Display volunteer scores in:
  - [ ] Admin dashboard (volunteers list)
  - [ ] Volunteer profile view
  - [ ] Team performance summary

**Estimated Effort**: 3-4 days

---

#### 1.2 Admin Rating Volunteers/Team Leaders (Flow #8.A)

**Goal**: Provide structured feedback mechanism for admins to rate users after events

- [ ] Create `AdminFeedback` model in [lib/Models/](lib/Models/)
  ```dart
  class AdminFeedback {
    String id;
    String adminId;
    String targetUserId; // volunteer or team leader
    String targetUserRole; // VOLUNTEER or TEAMLEADER
    String eventId;
    String shiftId;
    int overallRating; // 1-5
    Map<String, int> criteriaRatings; // criterion name -> score
    String comments;
    String timestamp;
  }
  ```
- [ ] Create `AdminFeedbackHelperFirebase`
  - [ ] CRUD operations
  - [ ] Get feedback by event
  - [ ] Get feedback by volunteer
  - [ ] Get feedback by team leader
- [ ] Create `AdminFeedbackProvider`
- [ ] Create `PostEventFeedbackScreen.dart`
  - [ ] Show after event completion
  - [ ] List all volunteers/team leaders in event
  - [ ] Quick rating interface (1-5 stars)
  - [ ] Optional detailed feedback
- [ ] Integrate with volunteer rating system
  - [ ] Admin feedback should contribute to volunteer score
- [ ] Firebase path: `/ihs/feedback/admin/{feedbackId}`

**Estimated Effort**: 2-3 days

---

#### 1.3 System Feedback (Bugs/Improvements) (Flow #8.B)

**Goal**: Allow users to report bugs and suggest improvements

- [ ] Create `SystemFeedback` model
  ```dart
  class SystemFeedback {
    String id;
    String userId;
    String userName;
    FeedbackType type; // BUG, FEATURE_REQUEST, IMPROVEMENT
    FeedbackPriority priority; // LOW, MEDIUM, HIGH
    String title;
    String description;
    String? screenshotUrl;
    FeedbackStatus status; // PENDING, IN_PROGRESS, RESOLVED, CLOSED
    String timestamp;
    String? resolvedBy;
    String? resolvedAt;
    String? resolutionNotes;
  }
  ```
- [ ] Create `SystemFeedbackHelperFirebase`
- [ ] Create `SystemFeedbackProvider`
- [ ] Create `SubmitFeedbackScreen.dart` (available to all users)
  - [ ] Category selection (Bug/Feature/Improvement)
  - [ ] Priority selection
  - [ ] Title and description
  - [ ] Optional screenshot upload
  - [ ] Submit button
- [ ] Create `FeedbackManagementScreen.dart` (Admin only)
  - [ ] List all feedback with filters
  - [ ] Filter by type, priority, status
  - [ ] View details
  - [ ] Change status
  - [ ] Add resolution notes
  - [ ] Assign to admin
- [ ] Add feedback button to all user dashboards
- [ ] Firebase path: `/ihs/feedback/system/{feedbackId}`

**Estimated Effort**: 2-3 days

---

#### 1.4 Volunteer Event Feedback (Flow #8.C)

**Goal**: Allow volunteers to provide feedback about event management

- [ ] Create `VolunteerEventFeedback` model
  ```dart
  class VolunteerEventFeedback {
    String id;
    String volunteerId;
    String eventId;
    String shiftId;
    int organizationRating; // 1-5
    int logisticsRating; // 1-5
    int communicationRating; // 1-5
    int managementRating; // 1-5
    String whatWentWell;
    String whatNeedsImprovement;
    List<String> issues; // predefined list: late start, poor communication, etc.
    String additionalComments;
    String timestamp;
    bool isAnonymous;
  }
  ```
- [ ] Create `VolunteerEventFeedbackHelperFirebase`
- [ ] Create `VolunteerEventFeedbackProvider`
- [ ] Create `SubmitEventFeedbackScreen.dart` (Volunteer only)
  - [ ] Show after event completion
  - [ ] Rating sliders (1-5) for each category
  - [ ] Text fields for open feedback
  - [ ] Checkbox for common issues
  - [ ] Anonymous option
  - [ ] Submit button
- [ ] Create `EventFeedbackReportScreen.dart` (Admin only)
  - [ ] View aggregated feedback per event
  - [ ] Average ratings per category
  - [ ] Common issues chart
  - [ ] Individual feedback list
  - [ ] Filter by event/date
- [ ] Auto-prompt volunteer to submit feedback 24 hours after event
- [ ] Firebase path: `/ihs/feedback/events/{eventId}/volunteers/{feedbackId}`

**Estimated Effort**: 3-4 days

---

### Priority 2: Reporting & Analytics (Medium Priority)

#### 2.1 Attendance Reports

- [ ] Create `ReportsScreen.dart` in [lib/UI/AdminScreens/](lib/UI/AdminScreens/)
- [ ] Export attendance to CSV
  - [ ] Event-level report
  - [ ] Volunteer-level report
  - [ ] Date range filtering
- [ ] Export attendance to PDF
  - [ ] Formatted tables
  - [ ] Event header
  - [ ] Statistics summary
- [ ] Attendance summary dashboard
  - [ ] Total events
  - [ ] Total volunteers
  - [ ] Average attendance rate
  - [ ] Absence trends

**Estimated Effort**: 2-3 days

---

#### 2.2 Volunteer Performance Analytics

- [ ] Create `VolunteerAnalyticsScreen.dart`
- [ ] Individual volunteer dashboard showing:
  - [ ] Total events participated
  - [ ] Attendance rate percentage
  - [ ] Average rating score
  - [ ] Leave request history
  - [ ] Feedback received
  - [ ] Performance trend chart
- [ ] Leaderboard view
  - [ ] Top-rated volunteers
  - [ ] Most active volunteers
  - [ ] Best attendance rate
- [ ] Export volunteer performance report

**Estimated Effort**: 3-4 days

---

#### 2.3 Event Statistics

- [ ] Event summary report:
  - [ ] Volunteer count per shift
  - [ ] Attendance statistics
  - [ ] Leave request count
  - [ ] Location utilization
  - [ ] Team performance
- [ ] Event comparison:
  - [ ] Compare multiple events
  - [ ] Identify trends
  - [ ] Best practices insights
- [ ] Export event statistics

**Estimated Effort**: 2-3 days

---

### Priority 3: Enhanced Features (Medium Priority)

#### 3.1 Volunteer Availability Management

- [ ] Create `Availability` model (volunteer sets available dates/times)
- [ ] Create `AvailabilityScreen.dart` for volunteers
  - [ ] Calendar view
  - [ ] Mark available/unavailable dates
  - [ ] Set recurring availability patterns
  - [ ] Set blackout dates
- [ ] Integrate with shift assignment
  - [ ] Only show available volunteers
  - [ ] Warning for unavailable assignments
  - [ ] Automatic conflict detection

**Estimated Effort**: 3-4 days

---

#### 3.2 Conflict Detection

- [ ] Check for volunteer double-booking
- [ ] Check for team leader conflicts
- [ ] Check for location capacity limits
- [ ] Display warnings during assignment
- [ ] Suggest alternative volunteers/times

**Estimated Effort**: 2 days

---

#### 3.3 Event Templates

- [ ] Create `EventTemplate` model
- [ ] Save event configurations as templates
- [ ] Template library screen
- [ ] Create event from template
- [ ] Edit and update templates
- [ ] Share templates between admins

**Estimated Effort**: 2-3 days

---

#### 3.4 Bulk Operations

- [ ] Bulk volunteer assignment
  - [ ] Select multiple volunteers
  - [ ] Assign to same shift
  - [ ] Assign to multiple shifts
- [ ] Bulk status updates
- [ ] Bulk notifications
- [ ] Import volunteers from CSV

**Estimated Effort**: 2-3 days

---

### Priority 4: Communication Enhancements (Low Priority)

#### 4.1 Email Notifications

- [ ] Set up Firebase Functions for emails
- [ ] Email templates
- [ ] Email for shift assignments
- [ ] Email for leave approvals
- [ ] Email for event reminders
- [ ] User email preferences

**Estimated Effort**: 3-4 days

---

#### 4.2 SMS Notifications

- [ ] Integrate SMS provider (Twilio/Firebase)
- [ ] SMS for critical notifications
- [ ] SMS for event reminders
- [ ] SMS opt-in/opt-out

**Estimated Effort**: 2-3 days

---

### Priority 5: Gamification & Recognition (Low Priority)

#### 5.1 Volunteer Badges/Achievements

- [ ] Create `Badge` model
- [ ] Define achievement criteria
- [ ] Award badges automatically
- [ ] Display badges on volunteer profile
- [ ] Badge notification system

**Estimated Effort**: 2-3 days

---

#### 5.2 Volunteer Certificates

- [ ] Certificate template design
- [ ] Auto-generate certificates
- [ ] Download/print certificates
- [ ] Email certificates

**Estimated Effort**: 2 days

---

#### 5.3 Volunteer Hour Tracking

- [ ] Calculate hours from attendance
- [ ] Display total hours on profile
- [ ] Hours leaderboard
- [ ] Export hours report

**Estimated Effort**: 1-2 days

---

### Priority 6: System Improvements (Ongoing)

#### 6.1 Automated Testing

- [ ] Unit tests for models
- [ ] Unit tests for helpers
- [ ] Widget tests for UI components
- [ ] Integration tests for workflows
- [ ] Set up CI/CD pipeline

**Estimated Effort**: 5-7 days

---

#### 6.2 Admin Activity Logs

- [ ] Create `ActivityLog` model
- [ ] Log all admin actions
- [ ] Log system changes
- [ ] Admin logs viewer screen
- [ ] Filter by user, action, date
- [ ] Export logs

**Estimated Effort**: 2-3 days

---

#### 6.3 Mobile App Support

- [ ] Add Android support
- [ ] Add iOS support
- [ ] Platform-specific UI adjustments
- [ ] Mobile push notifications
- [ ] Offline support

**Estimated Effort**: 10-15 days

---

#### 6.4 Performance Optimization

- [ ] Database indexing
- [ ] Lazy loading for large lists
- [ ] Image optimization
- [ ] Caching strategies
- [ ] Reduce Firebase reads

**Estimated Effort**: 3-5 days

---

### Total Estimated Effort Summary

| Priority                             | Tasks        | Estimated Days |
| ------------------------------------ | ------------ | -------------- |
| **Priority 1** (Core Workflows)      | 4 tasks      | 10-14 days     |
| **Priority 2** (Reporting)           | 3 tasks      | 7-10 days      |
| **Priority 3** (Enhanced Features)   | 4 tasks      | 9-13 days      |
| **Priority 4** (Communication)       | 2 tasks      | 5-7 days       |
| **Priority 5** (Gamification)        | 3 tasks      | 5-7 days       |
| **Priority 6** (System Improvements) | 4 tasks      | 20-30 days     |
| **TOTAL**                            | **20 tasks** | **56-81 days** |

---

_Last Updated: December 26, 2025_
