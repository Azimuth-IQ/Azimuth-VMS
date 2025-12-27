# Multi-Language Implementation Guide

## Overview

This application now supports English and Arabic languages. The localization system uses Flutter's built-in `flutter_localizations` package and ARB (Application Resource Bundle) files.

## Files Structure

```
lib/
├── l10n/
│   ├── app_en.arb     # English translations
│   └── app_ar.arb     # Arabic translations
├── Providers/
│   └── LanguageProvider.dart  # Language state management
└── UI/
    └── Widgets/
        └── LanguageSwitcher.dart  # Language switcher widget
```

## How to Use Localizations in Screens

### Step 1: Import AppLocalizations

Add this import to your screen file:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### Step 2: Get Localization Instance

In your build method, get the localizations:

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  // Now you can use l10n.keyName to get translated strings
}
```

### Step 3: Replace Hardcoded Strings

**Before:**

```dart
Text('Dashboard')
```

**After:**

```dart
Text(l10n.dashboard)
```

**Before:**

```dart
Text('Welcome back, $userPhone')
```

**After:**

```dart
Text(l10n.welcomeBack(userPhone))  // For strings with parameters
```

## Available Translation Keys

### Common

- `appTitle`, `welcome`, `search`, `save`, `cancel`, `delete`, `edit`, `add`, `update`, `submit`
- `close`, `confirm`, `back`, `next`, `previous`, `loading`, `error`, `success`
- `signOut`, `signIn`, `changePassword`, `yes`, `no`, `ok`, `retry`
- `upload`, `uploaded`, `download`, `print`, `select`, `selected`
- `assign`, `approve`, `reject`, `pending`, `approved`, `rejected`, `completed`
- `active`, `inactive`, `send`, `view`, `refresh`

### Navigation

- `dashboard`, `home`, `events`, `volunteers`, `leaders`, `teamLeaders`
- `teams`, `locations`, `notifications`, `sendNotif`, `sendNotification`
- `profile`, `settings`

### Dashboard

- `welcomeBack(userPhone)` - Takes user phone as parameter
- `analytics`, `quickActions`, `workflowScenarios`, `activeEvents`
- `volunteersPerTeam`, `noActiveEvents`, `activity`, `actions`
- `activityOverview`, `shiftsCompletedLast6Months`

### Statistics

- `activeEventsCount`, `volunteersCount`, `teamLeadersCount`, `notificationsCount`

### Quick Actions

- `shiftAssignment`, `presenceCheck`, `formsMgmt`, `carouselMgmt`
- `ratings`, `leaveRequests`, `systemFeedback`, `eventFeedback`

### Events

- `eventsManagement`, `createEvent`, `editEvent`, `deleteEvent`
- `eventName`, `eventDescription`, `startDate`, `endDate`
- `eventCreated`, `eventUpdated`, `eventDeleted`, `noEvents`, `selectEvent`

### Shifts

- `shifts`, `shiftTime`, `startTime`, `endTime`, `shift`
- `noShifts`, `selectShift`

### Team Leaders

- `teamLeadersManagement`, `addTeamLeader`, `editTeamLeader`, `deleteTeamLeader`
- `noTeamLeaders`, `tapPlusToAddTeamLeader`
- `teamLeaderArchived(name)`, `teamLeaderRestored(name)`, `teamLeaderDeleted(name)`

### Teams

- `teamsManagement`, `addTeam`, `editTeam`, `deleteTeam`, `teamName`, `noTeams`

### Locations

- `locationsManagement`, `addLocation`, `editLocation`, `deleteLocation`
- `locationName`, `mainLocation`, `subLocation`, `noLocations`, `selectLocation`, `location`

### Forms

- `volunteerForm`, `editVolunteerForm`, `basicInformation`, `contactInformation`
- `professionalInformation`, `documentInformation`, `attachments`, `createPdf`
- `formCreatedSuccessfully`, `formUpdatedSuccessfully`, `existingImage`

### Ratings

- `rateVolunteers`, `noVolunteersFound`, `rate`, `notRated`
- `lastRated(date)`, `pleaseConfigureCriteriaFirst`, `ratingCriteria`
- `notesOptional`, `addNote`, `saveRating`
- `ratingSaved(name)`, `errorSavingRating(error)`, `averageRating(rating)`

### Password

- `currentPassword`, `newPassword`, `confirmPassword`
- `passwordChangedSuccessfully`, `passwordMismatch`, `passwordTooShort`
- `wrongCurrentPassword`, `passwordSecurityTips`

### Errors

- `unknownError`, `networkError`, `permissionDenied`, `notFound`, `somethingWentWrong`

### Language

- `language`, `english`, `arabic`, `switchLanguage`, `languageChanged`

### General

- `name`, `phone`, `email`, `address`, `date`, `time`, `status`
- `description`, `notes`, `from`, `to`, `volunteer`, `teamLeader`
- `admin`, `all`, `none`, `unknown`, `unknownName`, `noPhone`

## Adding New Translations

### 1. Add to English ARB file (`lib/l10n/app_en.arb`)

```json
{
  "myNewKey": "My English Text",
  "myKeyWithParam": "Hello {name}!",
  "@myKeyWithParam": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

### 2. Add to Arabic ARB file (`lib/l10n/app_ar.arb`)

```json
{
  "myNewKey": "النص العربي",
  "myKeyWithParam": "مرحباً {name}!"
}
```

### 3. Run Flutter Pub Get

```bash
flutter pub get
```

This regenerates the `AppLocalizations` class with your new keys.

### 4. Use in Your Code

```dart
Text(l10n.myNewKey)
Text(l10n.myKeyWithParam('Ahmed'))
```

## Language Switcher Widget

Add language switcher to any screen:

```dart
import 'package:azimuth_vms/UI/Widgets/LanguageSwitcher.dart';

// In AppBar actions:
actions: [
  const LanguageSwitcher(showLabel: false, isIconButton: true),
  // other actions...
],

// Or as a standalone button:
LanguageSwitcher(showLabel: true, isIconButton: false)
```

## RTL (Right-to-Left) Support

Arabic is automatically displayed RTL. Flutter handles this automatically when the locale is set to Arabic.

To force a specific text direction in widgets:

```dart
Directionality(
  textDirection: TextDirection.rtl, // or TextDirection.ltr
  child: YourWidget(),
)
```

## Best Practices

1. **Never hardcode user-facing text** - Always use localizations
2. **Use descriptive key names** - `buttonSubmit` not `btn1`
3. **Group related keys** - Use prefixes like `error`, `success`, etc.
4. **Test both languages** - Switch languages and check all screens
5. **Handle plurals properly** - Use ICU message format for plurals
6. **Keep translations consistent** - Use the same term throughout the app

## Common Patterns

### SnackBar Messages

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(l10n.formCreatedSuccessfully)),
);
```

### Dialog Titles and Actions

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(l10n.confirm),
    content: Text(l10n.confirmDeleteCriterion(name)),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l10n.cancel),
      ),
      ElevatedButton(
        onPressed: () {
          // Delete action
          Navigator.pop(context);
        },
        child: Text(l10n.delete),
      ),
    ],
  ),
);
```

### Form Labels

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: l10n.name,
    hintText: l10n.enterPhoneNumber,
  ),
),
```

### Button Labels

```dart
ElevatedButton(
  onPressed: () => _save(),
  child: Text(isEdit ? l10n.update : l10n.add),
)
```

## Testing Localizations

1. **Switch languages in the app** using the LanguageSwitcher widget
2. **Check all screens** for proper text display
3. **Verify RTL layout** for Arabic (menus, lists, etc.)
4. **Test form validation messages** in both languages
5. **Check notifications** in both languages

## Troubleshooting

### "AppLocalizations not found"

Make sure you've run `flutter pub get` after adding/modifying ARB files.

### "Undefined name 'AppLocalizations'"

Add the import:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### Translation not updating

1. Save ARB files
2. Run `flutter pub get`
3. Hot restart (not hot reload) - Press Shift+R in terminal or click stop/run in IDE

### Missing translation key

Check both `app_en.arb` and `app_ar.arb` have the same keys.

## Implementation Checklist

For each screen, follow this checklist:

- [ ] Import `AppLocalizations`
- [ ] Get `l10n` instance in build method
- [ ] Replace all hardcoded strings with `l10n.keyName`
- [ ] Add language switcher to AppBar (optional, based on screen)
- [ ] Test in English
- [ ] Test in Arabic
- [ ] Verify RTL layout
- [ ] Check SnackBar messages
- [ ] Check dialog messages
- [ ] Check form validation messages

## Example Screen Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:azimuth_vms/UI/Widgets/LanguageSwitcher.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myScreenTitle),
        actions: const [
          LanguageSwitcher(showLabel: false, isIconButton: true),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.welcome),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.success)),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

**Last Updated**: December 27, 2025
