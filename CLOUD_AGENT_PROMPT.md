# Cloud Agent Prompt: VMS Theme System Implementation

**Copy this entire prompt and paste it as a comment on your GitHub Pull Request**

---

# Task: Implement 3-Theme Design System for VMS Flutter App

## ⚠️ CRITICAL: Branch & Repository Setup

**YOU MUST WORK ON THE CORRECT BRANCH:**

```bash
# First, verify which branch you're on
git branch

# If not on feature/theme-system-implementation, switch to it:
git checkout feature/theme-system-implementation

# Pull latest changes
git pull origin feature/theme-system-implementation

# Verify you're on the right branch
git branch
# Should show: * feature/theme-system-implementation
```

**DO NOT proceed until you confirm you're on `feature/theme-system-implementation` branch.**

---

## Context

You are working on a Flutter-based Volunteer Management System (VMS) that uses:
- **State Management:** Provider pattern (NO StatefulWidgets for UI state)
- **Database:** Firebase Realtime Database
- **Platform:** Web (Chrome) primary, iOS/Android secondary
- **Language:** Dart with Flutter

---

## Objective

Implement a role-based 3-theme design system where theme switches automatically based on user role:

| Theme | User Role | Colors | Platform |
|-------|-----------|--------|----------|
| Theme 1 | Admin | Red/Dark | Desktop + Mobile |
| Theme 2 | Volunteer | Green/Light | Mobile-First |
| Theme 3 | Team Leader | Gold/Dark | Mobile-First |

---

## Critical Project Rules (MUST FOLLOW)

### 1. Git Workflow
```bash
# ALWAYS commit before editing code
git add .
git commit -m "Descriptive message"
git push origin feature/theme-system-implementation
```

### 2. State Management
- ✅ Use Provider pattern with `Consumer` and `context.read()`
- ❌ NO StatefulWidget for UI state (exception: native controllers like GoogleMapController)

### 3. Firebase Data Handling
- ✅ Use `DataSnapshot` for all Firebase data
- ❌ NEVER use Maps for Firebase data
- Pattern:
```dart
Future<List<Event>> fetchEvents() async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('ihs/events');
  final DataSnapshot snapshot = await ref.get();
  final List<Event> events = [];
  
  for (final DataSnapshot d1 in snapshot.children) {
    final Event? event = Event.fromDataSnapshot(d1);
    if (event != null) {
      events.add(event);
    }
  }
  return events;
}
```

### 4. Error Handling
```dart
catch (e) {
  print('Error [context]: $e');  // ✅ ALWAYS print first
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### 5. STRICT TYPING (MANDATORY)

**ALWAYS use explicit types. NEVER use var, dynamic, or type inference.**

✅ **CORRECT:**
```dart
final String userName = 'Ahmed';
final int count = 42;
final List<String> names = ['Ali', 'Sara'];
final Map<String, dynamic> data = {'key': 'value'};
Color primaryColor = Theme.of(context).colorScheme.primary;
final SystemUser? user = snapshot.data;

Widget buildCard(BuildContext context, Event event) {
  final ThemeData theme = Theme.of(context);
  final double width = MediaQuery.of(context).size.width;
  return Container();
}
```

❌ **WRONG:**
```dart
var userName = 'Ahmed';              // NO var
dynamic count = 42;                  // NO dynamic
final names = ['Ali', 'Sara'];       // NO type inference
Map data = {'key': 'value'};         // NO omitted generics
var color = Theme.of(context).primary; // NO var
buildCard(context, event) { }        // NO omitted types
```

**Requirements:**
- All function parameters: explicit types
- All return types: declared
- All variables: explicit type declarations
- All collections: use generics (`List<T>`, `Map<K,V>`)
- Nullable types: use `?` operator
- Use `const` where possible

### 6. Documentation
- Update `README.md` after each major phase
- README.md is the ONLY project documentation

---

## Implementation Plan

### Phase 1: Theme Infrastructure (4-6 hours)

**Before starting:**
```bash
# Commit checkpoint
git add .
git commit -m "Phase 1 START: Theme infrastructure setup"
git push origin feature/theme-system-implementation
```

**1.1 Create Theme Files**

Create `lib/UI/Theme/Theme1.dart`:

```dart
import 'package:flutter/material.dart';

class Theme1 {
  // Primary Colors
  static const Color primary = Color(0xFFEC1313);
  static const Color primaryHover = Color(0xFFC91010);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F6F6);
  static const Color backgroundDark = Color(0xFF09090B);
  static const Color surfaceDark = Color(0xFF18181B);
  static const Color surfaceBorder = Color(0xFF27272A);
  static const Color surfaceHighlight = Color(0xFF3F3F46);
  
  // Text Colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);
  static const Color textMutedDark = Color(0xFF71717A);
  
  // Text Colors (Light Mode)
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  
  // Status Colors
  static const Color statusActive = Color(0xFF10B981);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusCompleted = Color(0xFF6366F1);
  static const Color statusCancelled = Color(0xFFEF4444);
  
  // Font
  static const String fontFamily = 'Inter';
  
  // Text Theme
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.4,
    ),
  );
  
  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: fontFamily,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryHover,
        background: backgroundDark,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimaryDark,
        onSurface: textPrimaryDark,
      ),
    );
  }
}
```

Create `lib/UI/Theme/Theme2.dart`:

```dart
import 'package:flutter/material.dart';

class Theme2 {
  // Primary Colors
  static const Color primary = Color(0xFF059669);
  static const Color primaryHover = Color(0xFF047857);
  static const Color primaryDark = Color(0xFF064E3B);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF0FDF4);
  static const Color backgroundDark = Color(0xFF064E3B);
  
  // Card Colors
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF065F46);
  
  // Text Colors (Light Mode)
  static const Color textPrimary = Color(0xFF022C22);
  static const Color textSecondary = Color(0xFF065F46);
  
  // Text Colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFECFDF5);
  static const Color textSecondaryDark = Color(0xFFA7F3D0);
  
  // Border Colors
  static const Color borderLight = Color(0xFFD1FAE5);
  static const Color borderDark = Color(0xFF047857);
  
  // Font
  static const String fontFamily = 'Lexend';
  
  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryHover,
        background: backgroundLight,
        surface: card,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
    );
  }
}
```

Create `lib/UI/Theme/Theme3.dart`:

```dart
import 'package:flutter/material.dart';

class Theme3 {
  // Primary Colors
  static const Color primary = Color(0xFFF4C025);
  static const Color primaryDark = Color(0xFFD6A410);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F8F5);
  static const Color backgroundDark = Color(0xFF013220);
  static const Color backgroundCard = Color(0xFF004D33);
  static const Color backgroundHeader = Color(0xFF00281A);
  
  // Text Colors
  static const Color textOffWhite = Color(0xFFF5F5DC);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color statusActive = Color(0xFF10B981);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusAbsent = Color(0xFFEF4444);
  
  // Fonts
  static const String displayFontFamily = 'Noto Serif';
  static const String bodyFontFamily = 'Noto Sans';
  
  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: bodyFontFamily,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryDark,
        background: backgroundDark,
        surface: backgroundCard,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onBackground: textPrimaryDark,
        onSurface: textPrimaryDark,
      ),
    );
  }
}
```

**1.2 Create ThemeProvider**

Create `lib/UI/Theme/ThemeProvider.dart`:

```dart
import 'package:flutter/material.dart';
import 'Theme1.dart';
import 'Theme2.dart';
import 'Theme3.dart';

enum UserRole { admin, volunteer, teamLeader }

class ThemeProvider with ChangeNotifier {
  UserRole? _currentRole;
  late ThemeData _currentTheme;
  
  ThemeProvider() {
    _currentTheme = Theme1.themeData;
  }
  
  ThemeData get currentTheme => _currentTheme;
  UserRole? get currentRole => _currentRole;
  
  void setThemeByRole(UserRole role) {
    _currentRole = role;
    ThemeData selectedTheme;
    
    switch (role) {
      case UserRole.admin:
        selectedTheme = Theme1.themeData;
        break;
      case UserRole.volunteer:
        selectedTheme = Theme2.themeData;
        break;
      case UserRole.teamLeader:
        selectedTheme = Theme3.themeData;
        break;
    }
    
    _currentTheme = selectedTheme;
    notifyListeners();
  }
  
  UserRole getUserRoleFromString(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'volunteer':
        return UserRole.volunteer;
      case 'teamleader':
      case 'team leader':
        return UserRole.teamLeader;
      default:
        return UserRole.volunteer;
    }
  }
}
```

**1.3 Create Helper Files**

Create `lib/UI/Theme/Breakpoints.dart`:

```dart
import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 640;
  static const double tablet = 1024;
  static const double desktop = 1280;
  
  static bool isMobile(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width < mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }
  
  static bool isDesktop(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width >= desktop;
  }
}
```

Create `lib/UI/Theme/Shadows.dart`:

```dart
import 'package:flutter/material.dart';

class Shadows {
  static const BoxShadow shadow1 = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow shadow2 = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow shadow3 = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
  
  static BoxShadow primaryShadow(Color primaryColor) {
    return BoxShadow(
      color: primaryColor.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    );
  }
}
```

**1.4 Update pubspec.yaml**

Check if fonts exist in `assets/fonts/`. If they do, add this to `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
    
    - family: Lexend
      fonts:
        - asset: assets/fonts/Lexend-Regular.ttf
        - asset: assets/fonts/Lexend-Medium.ttf
          weight: 500
        - asset: assets/fonts/Lexend-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Lexend-Bold.ttf
          weight: 700
    
    - family: Noto Serif
      fonts:
        - asset: assets/fonts/NotoSerif-Regular.ttf
        - asset: assets/fonts/NotoSerif-Bold.ttf
          weight: 700
        - asset: assets/fonts/NotoSerif-ExtraBold.ttf
          weight: 900
    
    - family: Noto Sans
      fonts:
        - asset: assets/fonts/NotoSans-Regular.ttf
        - asset: assets/fonts/NotoSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/NotoSans-Bold.ttf
          weight: 700
```

If fonts DON'T exist, create a comment in the code noting that fonts will use system defaults for now.

**1.5 Update main.dart**

Add ThemeProvider to the app:

```dart
// Find the existing MultiProvider in main.dart
// Add ThemeProvider to the providers list

ChangeNotifierProvider<ThemeProvider>(
  create: (BuildContext context) => ThemeProvider(),
),

// Update MaterialApp to use ThemeProvider
Consumer<ThemeProvider>(
  builder: (BuildContext context, ThemeProvider themeProvider, Widget? child) {
    return MaterialApp(
      theme: themeProvider.currentTheme,
      // ... rest of existing config
    );
  },
)
```

**1.6 Commit Phase 1**

```bash
git add .
git commit -m "Phase 1 COMPLETE: Theme infrastructure - 3 themes, ThemeProvider, helpers"
git push origin feature/theme-system-implementation
```

**STOP and report progress before continuing to Phase 2.**

---

### Phase 2: Base Components (6-8 hours)

Create reusable themed components. Each component MUST use explicit types.

**2.1 Create Directories**

```bash
mkdir -p lib/UI/Widgets/Buttons
mkdir -p lib/UI/Widgets/Forms
mkdir -p lib/UI/Widgets/Badges
mkdir -p lib/UI/Widgets/Cards
```

**2.2 Create PrimaryButton**

Create `lib/UI/Widgets/Buttons/PrimaryButton.dart`:

```dart
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  
  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    
    return SizedBox(
      width: width,
      height: 48.0,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _buildContent(),
      ),
    );
  }
  
  Widget _buildContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    return Text(text);
  }
}
```

**2.3 Create StatusBadge**

Create `lib/UI/Widgets/Badges/StatusBadge.dart`:

```dart
import 'package:flutter/material.dart';

enum BadgeStatus { active, pending, completed, cancelled, urgent }

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final String? customText;
  
  const StatusBadge({
    Key? key,
    required this.status,
    this.customText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String text = customText ?? _getStatusText();
    final Color backgroundColor = _getBackgroundColor();
    final Color textColor = _getTextColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  String _getStatusText() {
    switch (status) {
      case BadgeStatus.active:
        return 'Active';
      case BadgeStatus.pending:
        return 'Pending';
      case BadgeStatus.completed:
        return 'Completed';
      case BadgeStatus.cancelled:
        return 'Cancelled';
      case BadgeStatus.urgent:
        return 'Urgent';
    }
  }
  
  Color _getBackgroundColor() {
    switch (status) {
      case BadgeStatus.active:
        return const Color(0xFF10B981).withOpacity(0.1);
      case BadgeStatus.pending:
        return const Color(0xFFF59E0B).withOpacity(0.1);
      case BadgeStatus.completed:
        return const Color(0xFF6366F1).withOpacity(0.1);
      case BadgeStatus.cancelled:
      case BadgeStatus.urgent:
        return const Color(0xFFEF4444).withOpacity(0.1);
    }
  }
  
  Color _getTextColor() {
    switch (status) {
      case BadgeStatus.active:
        return const Color(0xFF10B981);
      case BadgeStatus.pending:
        return const Color(0xFFF59E0B);
      case BadgeStatus.completed:
        return const Color(0xFF6366F1);
      case BadgeStatus.cancelled:
      case BadgeStatus.urgent:
        return const Color(0xFFEF4444);
    }
  }
}
```

**Continue creating remaining components** following the same strict typing pattern.

**After completing all base components:**

```bash
git add .
git commit -m "Phase 2 COMPLETE: Base components - Buttons, Forms, Badges, Cards"
git push origin feature/theme-system-implementation
```

**STOP and report progress before Phase 3.**

---

### Phase 3: Navigation System (4-5 hours)

**Create navigation components to fix UX issues.**

**3.1 Create ResponsiveLayout**

Create `lib/UI/Widgets/Navigation/ResponsiveLayout.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../Theme/Breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? desktop;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.desktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bool isDesktopView = Breakpoints.isDesktop(context);
    
    if (isDesktopView && desktop != null) {
      return desktop!;
    }
    return mobile;
  }
}
```

**3.2 Create AdminSidebar (Desktop only)**

Create `lib/UI/Widgets/Navigation/AdminSidebar.dart` with all navigation items, proper styling, and active state detection.

**3.3 Create MobileBottomNav**

Create `lib/UI/Widgets/Navigation/MobileBottomNav.dart` with max 4-5 items based on user role.

**After completing navigation:**

```bash
git add .
git commit -m "Phase 3 COMPLETE: Responsive navigation - AdminSidebar, MobileBottomNav, ResponsiveLayout"
git push origin feature/theme-system-implementation
```

**STOP and report progress before Phase 4.**

---

### Phase 4: Screen Updates (8-12 hours)

Update each screen one at a time, test, commit.

**Pattern per screen:**

1. Wrap with ResponsiveLayout
2. Replace hardcoded colors with `Theme.of(context)`
3. Use new themed components
4. Ensure explicit types throughout
5. Test functionality
6. Commit

**After all screens updated:**

```bash
git add .
git commit -m "Phase 4 COMPLETE: All screens migrated to theme system"
git push origin feature/theme-system-implementation
```

**STOP and report progress before Phase 5.**

---

### Phase 5: Testing & Documentation (2-3 hours)

**Run all tests, update README.md, final review.**

```bash
git add .
git commit -m "Phase 5 COMPLETE: Testing done, documentation updated"
git push origin feature/theme-system-implementation
```

---

## Final Deliverables

- [ ] 3 theme files (Theme1, Theme2, Theme3)
- [ ] ThemeProvider with role-based switching
- [ ] Base component library
- [ ] Responsive navigation system
- [ ] All screens migrated
- [ ] README.md updated
- [ ] Zero uses of var/dynamic
- [ ] All tests passing
- [ ] No console errors

---

## Success Criteria

✅ Theme switches on login by user role  
✅ All screens use theme colors (no hardcoded)  
✅ Admin desktop shows sidebar  
✅ Mobile shows bottom nav (max 4-5 items)  
✅ All fonts render correctly  
✅ No functional regressions  
✅ README.md updated  
✅ Strict typing enforced  

---

**Work incrementally. Commit after each phase. Report progress. Wait for approval before merging.**
