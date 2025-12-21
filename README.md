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

### 4. Team
Groups of volunteers organized for specific tasks.
- **Fields**: `id`, `name`, `leaderId`, `members` (List of Volunteer IDs).

### 5. SystemUser
Admin and staff users who manage the system.
- **Fields**: `uid`, `email`, `role` (Admin, Manager, Staff).

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

---

## Current Project State

### ✅ Implemented Features
- **Form Management Dashboard**:
  - List view of all volunteer forms.
  - Real-time search by name or phone number.
  - Status filtering (e.g., Show only "Pending" forms).
  - Visual document status indicators (Green check/Red X).
  - Quick status updates via dropdown.
- **Volunteer Registration Form**:
  - Multi-step stepper interface (Basic Info, Contact, Professional, Documents, Attachments).
  - Image upload integration with Firebase Storage.
  - Edit mode for existing forms (pre-filled data).
  - PDF generation and download/print.
- **Firebase Integration**:
  - Full CRUD operations for Volunteer Forms.
  - Image storage structure: `ihs/volunteerForms/{phoneNumber}/{imageName}`.

### 🚧 Pending / In Progress
- Event management module.
- Team assignment logic.
- Advanced reporting and analytics.
- Role-based access control (RBAC) refinement.

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
3. Add the key to `web/index.html`:
   ```html
   <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
   ```

### 4. Run the App
```bash
flutter run -d chrome
```

---

## User Manual

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
   - *Note: If editing, existing images will be shown with a "Saved" indicator.*
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

### Firebase Storage Structure
#### `/ihs/volunteerForms/{mobileNumber}/`
- `photo.jpg`: Personal photo
- `id_front.jpg`: National ID Front
- `id_back.jpg`: National ID Back
- `residence_front.jpg`: Residence Card Front
- `residence_back.jpg`: Residence Card Back

### Helper Classes
- **`VolunteerFormHelperFirebase`**:
  - `CreateForm(VolunteerForm form)`: Creates a new record.
  - `UpdateForm(VolunteerForm form)`: Updates existing record.
  - `GetAllForms()`: Returns `List<VolunteerForm>`.
  - `GetFormByMobileNumber(String mobile)`: Returns single `VolunteerForm`.

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
- **Solution**: Check `web/index.html` and ensure the API key is valid and has "Maps JavaScript API" enabled in Google Cloud Console.

#### 4. PDF Text Rendering Issues
- **Cause**: Arabic font support in PDF generation.
- **Solution**: Ensure the font assets are correctly loaded and the `syncfusion_flutter_pdf` package is configured to use a font that supports Arabic characters if you see boxes instead of text.

---
*Last Updated: December 21, 2025*
