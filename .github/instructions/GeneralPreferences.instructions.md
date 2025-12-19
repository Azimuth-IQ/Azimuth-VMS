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

## UI/UX Preferences

- Show loading indicators during async operations
- Provide clear error messages to users
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
