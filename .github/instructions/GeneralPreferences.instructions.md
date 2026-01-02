---
applyTo: "**"
---

# Development Preferences & Guidelines

## ⚠️ IMPORTANT: Before Starting Any Work

**Always create a git commit before editing any code to ensure safe rollback:**

```bash
git add .
git commit -m "Pre-edit checkpoint: [brief description of upcoming changes]"
```

---

## Multi-Language Support (Arabic & English)

- **ALL UI text must be bilingual** - Never use hardcoded English/Arabic strings
- **Always use AppLocalizations** for any user-facing text:
  ```dart
  Text(AppLocalizations.of(context)!.keyName)
  ```
- **Add missing keys** to both `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`
- **Button labels, titles, descriptions** - Everything visible to users must be localized
- **Check existing keys first** before adding new ones to avoid duplicates
- Pattern for new keys:

  ```json
  // app_en.arb
  "keyName": "English Text",

  // app_ar.arb
  "keyName": "النص العربي",
  ```

- **Never use:**
  - `const Text('Hardcoded English')`
  - `Text('Hard coded text')`
  - Mixed language in single widget

### ⚡ CRITICAL: After Adding Localization Keys

**ALWAYS run these two steps after adding new keys to .arb files:**

1. **Add keys to BOTH files** - `lib/l10n/app_en.arb` AND `lib/l10n/app_ar.arb`
2. **Regenerate localization classes** - Run this command:
   ```bash
   flutter gen-l10n
   ```

Without running `flutter gen-l10n`, the new keys won't be available in `AppLocalizations` and you'll get "undefined getter" errors.

---

## State Management

- **Use Provider pattern exclusively** - No StatefulWidgets for UI state management
- Create dedicated providers for each feature (e.g., LocationsProvider, LocationFormProvider)
- Use `Consumer` and `context.read()` for accessing provider state
- Keep business logic in providers, not in widgets
- Only exception: Widgets requiring native controllers (e.g., GoogleMapController) can be StatefulWidget

---

## Firebase Data Handling

- **Always use DataSnapshot, never Maps** when working with Firebase data
- Iterate through snapshots using `snapshot.children` with for loops
- Pattern:
  ```dart
  DataSnapshot snapshot = await ref.get();
  for (DataSnapshot d1 in snapshot.children) {
    // Process d1
  }
  ```
- Use `snapshot.child('fieldName').value` to access individual fields
- Use `snapshot.exists` to check if data exists before processing

---

## Error Handling

- **Always add print statements** before showing error SnackBars
- Pattern:
  ```dart
  catch (e) {
    print('Error [context]: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  ```

---

## Location & Maps

- **Default coordinates**: Baghdad, Iraq
  - Latitude: `33.3152`
  - Longitude: `44.3661`
- Google Maps API key must be configured in `web/index.html` with `key=` parameter
- Ensure billing is enabled in Google Cloud Console for Maps API

---

## Code Organization

- Keep models in `lib/Models/`
- Keep providers in `lib/Providers/`
- Keep Firebase helpers in `lib/Helpers/`
- Keep UI screens in `lib/UI/Screens/`
- Keep reusable widgets in `lib/UI/Widgets/`

---

## Dependencies

- Use `provider` package for state management
- Use `google_maps_flutter` and `google_maps_flutter_web` for maps
- Use `firebase_database` for Firebase Realtime Database
- Use `uuid` for generating unique IDs

---

## Best Practices

- Use stateless widgets with providers instead of stateful widgets
- Prefer composition over inheritance
- Keep widgets small and focused
- Extract reusable components
- Use proper validation in forms
- Always handle null safety properly
- Use meaningful variable names

---

## File Naming & Documentation

- Use PascalCase for class files (e.g., `LocationsMgmt.dart`)
- Use snake_case for provider files (e.g., `locations_provider.dart`)
- When referencing files in documentation, use proper markdown links
- Avoid backticks for file names in documentation

---

## 📝 CRITICAL: Documentation Requirements

**⚠️ The README.md file is the ONLY project documentation**

After every configuration, feature implementation, or significant change, **you MUST update README.md** to include:

### Required README Sections:

1. **Business Models** - Complete description of all data models and their relationships
2. **Technical Capabilities** - All features, integrations, and technical implementations
3. **Current Project State** - What works, what's configured, what's pending
4. **Setup Instructions** - Step-by-step guide for Firebase, APIs, and dependencies
5. **User Manual** - How to use each feature with screenshots/examples where applicable
6. **API Documentation** - All Firebase paths, data structures, and helper functions
7. **Troubleshooting** - Common issues and solutions

### Documentation Rules:

- **NO separate documentation files** (delete FIREBASE_STORAGE_SETUP.md, API_DOCS.md, etc.)
- **Everything goes in README.md** - Keep it comprehensive but organized
- **Update after every major change** - README should always reflect current state
- **Write for non-technical users** - Assume reader has no prior knowledge
- **Include code examples** - Show actual usage patterns
- **Keep it current** - Remove outdated information immediately

Think of README.md as the **complete product manual** that anyone can use to understand, set up, and operate the entire system.

---

## UI/UX Preferences

- **All text must be bilingual** using AppLocalizations
- Show loading indicators during async operations
- Provide clear error messages to users (localized)
- Use confirmation dialogs for destructive actions
- Keep forms clean with proper validation
- Use icons to improve visual clarity
- Implement refresh functionality where applicable

---

## Testing & Safety

- Test changes on Chrome web platform first (since macOS doesn't support google_maps_flutter natively)
- Always verify Firebase data structure after updates
- Check for console errors and fix them before committing
- Run `flutter pub get` after adding dependencies
- Use hot reload (r) for UI changes, hot restart (R) for logic changes

---

_Last Updated: December 19, 2025_
