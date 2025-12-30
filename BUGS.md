# VMS Bug Tracking & TODO List

**Last Updated:** December 30, 2025

---

## ✅ Completed Bugs (1-3)

### Bug 1: Rating Criteria Not Refreshing ✅

- **Issue:** Rating criteria fields not updating when switching between volunteers
- **Status:** FIXED
- **Solution:** Forced form state refresh in rating screen

### Bug 2: Mobile Font Overflow ✅

- **Issue:** Font sizes too large on mobile, causing text overflow
- **Status:** FIXED
- **Solution:** Reduced font sizes by ~35% in mobile breakpoints

### Bug 3: PDF Arabic Labels ✅

- **Issue:** PDF form labels in Arabic not displaying correctly
- **Status:** FIXED
- **Solution:** Changed PDF labels to English

### Bug 13: Leave Request on Volunteer Pages ✅

- **Issue:** Leave request is not available on volunteers pages and dashboard
- **Status:** FIXED
- **Solution:** Added "My Schedule" navigation option to both desktop (NavigationRail) and mobile (BottomNavigationBar) views. Volunteers can now access their schedule and request leave for specific shifts from the dashboard.
- **Files Modified:** [VolunteersDashboard.dart](lib/UI/VolunteerScreens/VolunteersDashboard.dart)

### Bug 12: Relocate Volunteer Flow ✅

- **Issue:** Relocate volunteer flow is not working at all, not initiating new presence check
- **Status:** FIXED
- **Solution:** Updated LocationReassignmentDialog to create a new ARRIVAL attendance check when volunteer is relocated to a new location. This ensures they must check in at the new location and attendance is properly tracked.
- **Files Modified:** [LocationReassignmentDialog.dart](lib/UI/AdminScreens/LocationReassignmentDialog.dart)
- **Localization Added:** `locationReassignedSuccessfully` in English and Arabic

### Bug 10: Location/Sublocation Display Showing ID Instead of Name ✅

- **Issue:** Most location and sublocation cards showing location ID instead of name
- **Status:** FIXED
- **Solution:** Added location name lookup in multiple screens:
  - VolunteerScheduleScreen: Added LocationHelper and location cache, displays "Location - Sublocation" format
  - EventsMgmt: Uses EventsProvider locations to show names instead of IDs in shift lists
- **Files Modified:**
  - [VolunteerScheduleScreen.dart](lib/UI/VolunteerScreens/VolunteerScheduleScreen.dart)
  - [EventsMgmt.dart](lib/UI/AdminScreens/EventsMgmt.dart)

### Bug 18: Language Selector on Sign In ✅

- **Issue:** Implement language selector on the sign in page
- **Status:** FIXED
- **Solution:** Added PopupMenuButton in top-right corner with EN/AR language options. Uses LanguageProvider to switch locale dynamically. Selected language is highlighted.
- **Files Modified:** [SignInScreen.dart](lib/UI/SignInScreen.dart)
- **Localization Added:** Language names in both English and Arabic

### Bug 19: Form Fields Width on Mobile ✅

- **Issue:** All form fields should be full width on mobile - labels and hints don't fully appear due to limited width
- **Status:** FIXED
- **Solution:** Created responsive `_buildResponsiveRow` helper that returns Column (full width) on mobile (< 640px) and Row with Expanded children on desktop. Replaced all form field Row widgets with responsive version.
- **Files Modified:** [FormFillPage.dart](lib/UI/VolunteerScreens/FormFillPage.dart)
- **Changes:**
  - Added `_buildResponsiveRow` helper method
  - Converted 6 form rows to responsive layout (personal info, contact info, professional info, document info)
  - Form fields now stack vertically on mobile, display side-by-side on desktop

### Bug 11: "Assigned By" Display ✅

- **Issue:** "Assigned by" showing cards has phone number instead of admin's/team leader's name
- **Status:** FIXED
- **Solution:** Added system user lookup in all assignment display screens to show names instead of phone numbers
- **Files Modified:**
  - [VolunteerScheduleScreen.dart](lib/UI/VolunteerScreens/VolunteerScheduleScreen.dart) - Already had `_getAssignerName()` helper
  - [ShiftAssignmentScreen.dart](lib/UI/AdminScreens/ShiftAssignmentScreen.dart) - Already had `assignedByUser?.name` lookup
  - [TeamLeaderShiftManagementScreen.dart](lib/UI/TeamLeadersScreens/TeamLeaderShiftManagementScreen.dart) - Added `assignedByUser` lookup

### Bug 9: Search Feature in Dialogs ✅

- **Issue:** Add search feature to dialogs with lists (volunteers, team leaders, locations)
- **Status:** FIXED
- **Solution:** Added search TextField to selection dialogs with real-time filtering by name or phone
- **Files Modified:**
  - [TeamLeaderShiftManagementScreen.dart](lib/UI/TeamLeadersScreens/TeamLeaderShiftManagementScreen.dart) - Added search to `_VolunteerSelectionDialog`
  - [EventsMgmt.dart](lib/UI/AdminScreens/EventsMgmt.dart) - Converted `_selectMember` AlertDialog to stateful `_MemberSelectionDialog` with search
- **Localization Added:** `searchByNameOrPhone`, `noResultsFound` in English and Arabic
- **Features:**
  - Search filters list in real-time (case-insensitive)
  - Shows "no results found" when no matches
  - Search works by name or phone number

---

## 🔄 In Progress

### PDF Generation Arabic Text Issues

- **Issue:** Arabic text rendering issues in PDF
- **Current Status:** Using form1.pdf with simple field filling
- **Known Limitations:**

  - Character 1544 (؈ Arabic Ray) in template causes flatten errors
  - Scattered letters when using custom fonts
  - Flattening disabled to allow PDF generation

- **Temporary Solution:** PDF generates without flattening (fields remain editable)
- **Long-term Fix Needed:** Create new PDF template in Adobe with:
  - Proper Arabic font (Cairo or Amiri) embedded
  - Remove character 1544 from all labels/headers
  - Test flattening works correctly

---

## 🐛 Pending Bugs (4-19)

### Bug 4: Bilingual Photo Upload Hint

- **Issue:** Add bilingual hint (Arabic/English) for upload personal image field
- **Details:** Specify that volunteer needs to wear formal clothing on white background
- **Priority:** Medium
- **Status:** Not Started
- **Affected Screen:** Volunteer form fill page

### Bug 5: Slider/Carousel Feature

- **Issue:** Implement creation of slider to be displayed in a time frame in the future
- **Priority:** Medium
- **Status:** Not Started
- **Type:** Feature Request

### Bug 6: Image Optimization

- **Issue:** Implement simple UI to crop, resize and compress images to below 500KB on frontend
- **Details:** Some cameras have high quality with large image sizes
- **Priority:** Medium
- **Status:** Not Started
- **Affected Screen:** Volunteer form image upload

### Bug 7: Review Automatic Notifications

- **Issue:** Document what automatic notifications are implemented
- **Details:** Check what more notifications to send automatically
- **Priority:** Low
- **Status:** Not Started
- **Type:** Review/Documentation

### Bug 8: Firebase Web Auth Key

- **Issue:** Implement Firebase web auth key for push notifications
- **Details:** Key: `BDEQjN1UbATEWI8TY1tTHakqvCw5EpryE6OGIirk4hqBG7CCLO-0O0eL97nVmEAKa6Ms7EoI9MaezpKndlgeOHs`
- **Priority:** High
- **Status:** Not Started
- **Files:** `web/firebase-messaging-sw.js`, notification helpers

### Bug 14: Carousel Slider Inconsistency

- **Issue:** Inconsistency in showing carousel slider (admin, volunteer, team leader)
- **Details:** Sometimes appears, sometimes doesn't with no logs
- **Priority:** Medium
- **Status:** Not Started
- **Affected Screens:** All dashboards (admin, volunteer, team leader)

### Bug 15: Theme Settings Not Clickable on PC

- **Issue:** Theme settings is not clickable on PC, but clicks on mobile
- **Priority:** Medium
- **Status:** Not Started
- **Affected Screen:** Settings page

### Bug 16: Theme Settings Not Translatable

- **Issue:** Theme settings is not translatable in Arabic mode
- **Priority:** Medium
- **Status:** Not Started
- **Affected Screen:** Settings page
- **Files:** `lib/l10n/intl_*.arb`

### Bug 17: Default Language to Arabic

- **Issue:** Implement Arabic as the starting/default language
- **Priority:** Medium
- **Status:** Not Started
- **Files:** `lib/main.dart`, language provider

---

## 📋 Feature Requests & Enhancements

### Priority 1: Feedback Systems (Not Implemented)

#### 1.1 Volunteer Rating System UI

- **Status:** Models exist, no Helper/Provider/UI
- **Files Needed:**
  - `lib/Helpers/VolunteerRatingHelperFirebase.dart`
  - `lib/Providers/VolunteerRatingProvider.dart`
  - `lib/UI/AdminScreens/VolunteerRatingScreen.dart`
- **Estimate:** 2-3 days

#### 1.2 Admin Rating System

- **Status:** Not started
- **Description:** Admins rate volunteers/team leaders after events
- **Estimate:** 2-3 days

#### 1.3 System Feedback

- **Status:** Not started
- **Description:** Users report bugs and suggest improvements
- **Estimate:** 2-3 days

#### 1.4 Volunteer Event Feedback

- **Status:** Not started
- **Description:** Volunteers provide feedback on event management
- **Estimate:** 2-3 days

### Priority 2: Reporting & Analytics

- **Status:** Not started
- **Features Needed:**
  - CSV/PDF export functionality
  - Analytics dashboards
  - Performance metrics
  - Attendance reports
- **Estimate:** 5-7 days

---

## 🔧 Technical Debt

### 1. Google Fonts Package

- **Issue:** Added `google_fonts: ^6.2.1` for PDF generation but not actively used
- **Action:** Keep for potential future use or remove if not needed

### 2. PDF Templates Organization

- **Current State:** Multiple PDF templates (form1, form2, form3, form4) in assets/pdfs/
- **Action:** Consolidate to one working template once Arabic issue resolved

### 3. Theme System Implementation

- **Status:** Partially implemented (see PRE_DELEGATION_CHECKLIST.md and CLOUD_AGENT_PROMPT.md)
- **Files:** REDESIGN.md, THEME_IMPLEMENTATION_GUIDE.md
- **Action:** Complete theme system per design specifications

---

## 📝 Notes for Developers

### Before Starting Any Bug Fix:

```bash
# Always create checkpoint commit
git add .
git commit -m "Pre-edit checkpoint: Fix Bug #X - [description]"
```

### After Completing Bug Fix:

1. Test on Chrome web browser
2. Verify no console errors
3. Update this BUGS.md file (move to Completed section)
4. Update README.md if feature documentation needed
5. Commit with descriptive message:
   ```bash
   git add .
   git commit -m "Fix Bug #X: [description of fix]"
   ```

### Testing Checklist:

- [ ] Chrome web browser tested
- [ ] No console errors
- [ ] Firebase operations work
- [ ] Real-time updates function
- [ ] Error handling works
- [ ] Loading states display correctly
- [ ] Notifications trigger (if applicable)

---

## 🎯 Next Steps

1. **Document Bugs 5-19** - Get detailed descriptions from client/testing
2. **Fix Bug 4** - Add bilingual photo upload hint
3. **Resolve PDF Arabic issue** - Create proper template in Adobe
4. **Continue with Bugs 5-19** - Work through systematically
5. **Implement Priority 1 Features** - Volunteer rating UI, feedback systems
6. **Complete Theme System** - If still pending

---

**For questions or clarifications, refer to:**

- [README.md](README.md) - Complete project documentation
- [.github/instructions/GeneralPreferences.instructions.md](.github/instructions/GeneralPreferences.instructions.md)
- [.github/instructions/SystemAnalysis.instructions.md](.github/instructions/SystemAnalysis.instructions.md)
