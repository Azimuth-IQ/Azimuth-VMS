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

### Bug 4: Photo Upload Hint
- **Issue:** Add bilingual hint (Arabic/English) for photo upload field
- **Priority:** Medium
- **Status:** Not Started

### Bug 5: [To be documented]
- **Status:** Not Started

### Bug 6: [To be documented]
- **Status:** Not Started

### Bug 7: [To be documented]
- **Status:** Not Started

### Bug 8: [To be documented]
- **Status:** Not Started

### Bug 9: [To be documented]
- **Status:** Not Started

### Bug 10: [To be documented]
- **Status:** Not Started

### Bug 11: [To be documented]
- **Status:** Not Started

### Bug 12: [To be documented]
- **Status:** Not Started

### Bug 13: [To be documented]
- **Status:** Not Started

### Bug 14: [To be documented]
- **Status:** Not Started

### Bug 15: [To be documented]
- **Status:** Not Started

### Bug 16: [To be documented]
- **Status:** Not Started

### Bug 17: [To be documented]
- **Status:** Not Started

### Bug 18: [To be documented]
- **Status:** Not Started

### Bug 19: [To be documented]
- **Status:** Not Started

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
