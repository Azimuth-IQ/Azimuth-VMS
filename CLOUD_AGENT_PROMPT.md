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

**Companion Documentation:**

- `THEME_IMPLEMENTATION_GUIDE.md` - Streamlined guide with git workflow and phase checklist
- `REDESIGN.md` - Complete design specification with 47 pages of component details
- `PRE_DELEGATION_CHECKLIST.md` - Pre-work checklist (fonts, git setup, verification)

**Read these files for context, but follow THIS prompt for implementation instructions.**

---

## Objective

Implement a unified 3-theme design system where:

- **One theme applies to the entire platform** (all users see the same theme)
- **Admins can select** from 3 pre-made themes via admin panel
- **Theme colors are customizable** (main, accent, text colors, etc.)
- **Color purposes clearly documented** in code comments

| Theme   | Visual Style | Main Color      | Accent Color         | Description        |
| ------- | ------------ | --------------- | -------------------- | ------------------ |
| Theme 1 | Red/Dark     | #EC1313 (Red)   | #C91010 (Dark Red)   | Authority, urgency |
| Theme 2 | Green/Light  | #059669 (Green) | #047857 (Dark Green) | Growth, community  |
| Theme 3 | Gold/Dark    | #F4C025 (Gold)  | #D6A410 (Dark Gold)  | Warmth, leadership |

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

/// Theme 1: Red/Dark - Authority and Urgency
/// Visual Style: Dark theme with red as main color
/// Use Case: Professional, serious applications
class Theme1 {
  // ============================================
  // MAIN COLORS - Primary brand colors
  // ============================================

  /// Main Color - Used for primary actions, buttons, highlights
  static const Color mainColor = Color(0xFFEC1313); // Bright Red

  /// Accent Color - Used for hover states, secondary actions
  static const Color accentColor = Color(0xFFC91010); // Dark Red

  // ============================================
  // BACKGROUND COLORS - Page and surface colors
  // ============================================

  /// Background Color (Light Mode) - Main page background for light theme
  static const Color backgroundLight = Color(0xFFF8F6F6); // Light Gray

  /// Background Color (Dark Mode) - Main page background for dark theme
  static const Color backgroundDark = Color(0xFF09090B); // Almost Black (zinc-950)

  /// Surface Color - Used for cards, dialogs, elevated components
  static const Color surfaceColor = Color(0xFF18181B); // zinc-900

  /// Border Color - Used for dividers, borders
  static const Color borderColor = Color(0xFF27272A); // zinc-800

  /// Highlight Color - Used for subtle highlights, hovers
  static const Color highlightColor = Color(0xFF3F3F46); // zinc-700

  // ============================================
  // TEXT COLORS - Typography colors
  // ============================================

  /// Primary Text Color (Dark Mode) - Main text on dark backgrounds
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White

  /// Secondary Text Color (Dark Mode) - Less important text on dark backgrounds
  static const Color textSecondaryDark = Color(0xFFA1A1AA); // zinc-400

  /// Muted Text Color (Dark Mode) - Disabled or very subtle text
  static const Color textMutedDark = Color(0xFF71717A); // zinc-500

  /// Primary Text Color (Light Mode) - Main text on light backgrounds
  static const Color textPrimaryLight = Color(0xFF0F172A); // slate-900

  /// Secondary Text Color (Light Mode) - Less important text on light backgrounds
  static const Color textSecondaryLight = Color(0xFF64748B); // slate-500

  // ============================================
  // STATUS COLORS - Semantic colors for states
  // ============================================

  /// Success Color - Used for success states, active status
  static const Color statusSuccess = Color(0xFF10B981); // green-500

  /// Warning Color - Used for warnings, pending status
  static const Color statusWarning = Color(0xFFF59E0B); // amber-500

  /// Info Color - Used for informational messages, completed status
  static const Color statusInfo = Color(0xFF6366F1); // indigo-500

  /// Error Color - Used for errors, cancelled status, destructive actions
  static const Color statusError = Color(0xFFEF4444); // red-500

  // Legacy aliases for backward compatibility
  static const Color primary = mainColor;
  static const Color primaryHover = accentColor;
  static const Color surfaceDark = surfaceColor;
  static const Color surfaceBorder = borderColor;
  static const Color surfaceHighlight = highlightColor;
  static const Color statusActive = statusSuccess;
  static const Color statusPending = statusWarning;
  static const Color statusCompleted = statusInfo;
  static const Color statusCancelled = statusError;

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
  // ==================== MAIN COLORS ====================
  // Primary action color - Used for main buttons, links, highlighted elements
  static const Color mainColor = Color(0xFF059669);  // Green - Growth and community

  // Secondary action color - Used for hover states and secondary actions
  static const Color accentColor = Color(0xFF047857);  // Dark Green

  // Legacy aliases for backward compatibility
  static const Color primary = mainColor;
  static const Color primaryHover = accentColor;
  static const Color primaryDark = Color(0xFF064E3B);  // Very Dark Green - Rarely used

  // ==================== BACKGROUND COLORS ====================
  // Main page background for light mode
  static const Color backgroundLight = Color(0xFFF0FDF4);  // Very Light Green Tint

  // Main page background for dark mode (future use)
  static const Color backgroundDark = Color(0xFF064E3B);  // Very Dark Green

  // Card/surface color for light mode
  static const Color card = Color(0xFFFFFFFF);  // White - Clean cards

  // Card/surface color for dark mode (future use)
  static const Color cardDark = Color(0xFF065F46);  // Dark Green

  // ==================== TEXT COLORS ====================
  // Primary text color for light mode - Main content
  static const Color textPrimary = Color(0xFF022C22);  // Almost Black with Green Tint

  // Secondary text color for light mode - Descriptions, labels
  static const Color textSecondary = Color(0xFF065F46);  // Muted Dark Green

  // Primary text color for dark mode - Main content (future use)
  static const Color textPrimaryDark = Color(0xFFECFDF5);  // Very Light Green

  // Secondary text color for dark mode - Descriptions, labels (future use)
  static const Color textSecondaryDark = Color(0xFFA7F3D0);  // Light Green

  // ==================== BORDER COLORS ====================
  // Border color for light mode - Dividers, card borders
  static const Color borderLight = Color(0xFFD1FAE5);  // Light Green Tint

  // Border color for dark mode - Dividers, card borders (future use)
  static const Color borderDark = Color(0xFF047857);  // Dark Green

  // ==================== STATUS COLORS ====================
  // Success state color
  static const Color statusSuccess = Color(0xFF059669);  // Same as mainColor

  // Warning state color
  static const Color statusWarning = Color(0xFFF59E0B);  // Amber

  // Info state color
  static const Color statusInfo = Color(0xFF3B82F6);  // Blue

  // Error state color
  static const Color statusError = Color(0xFFEF4444);  // Red

  // Font
  static const String fontFamily = 'Lexend';

  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: mainColor,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: mainColor,
        secondary: accentColor,
        background: backgroundLight,
        surface: card,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
      dividerColor: borderLight,
    );
  }
}
```

Create `lib/UI/Theme/Theme3.dart`:

```dart
import 'package:flutter/material.dart';

class Theme3 {
  // ==================== MAIN COLORS ====================
  // Primary action color - Used for main buttons, links, highlighted elements
  static const Color mainColor = Color(0xFFF4C025);  // Gold - Warmth and leadership

  // Secondary action color - Used for hover states and secondary actions
  static const Color accentColor = Color(0xFFD6A410);  // Dark Gold

  // Legacy aliases for backward compatibility
  static const Color primary = mainColor;
  static const Color primaryDark = accentColor;

  // ==================== BACKGROUND COLORS ====================
  // Main page background for light mode (rarely used - this is dark theme)
  static const Color backgroundLight = Color(0xFFF8F8F5);  // Off-White

  // Main page background for dark mode
  static const Color backgroundDark = Color(0xFF013220);  // Very Dark Green - Deep elegance

  // Card/surface color for dark mode
  static const Color backgroundCard = Color(0xFF004D33);  // Dark Green Card

  // Header/elevated surface color for dark mode
  static const Color backgroundHeader = Color(0xFF00281A);  // Darkest Green

  // ==================== TEXT COLORS ====================
  // Primary text color for dark mode - Main content
  static const Color textPrimaryDark = Color(0xFFFFFFFF);  // Pure White - Maximum readability

  // Secondary/accent text color for dark mode - Warm tone
  static const Color textOffWhite = Color(0xFFF5F5DC);  // Beige/Warm White

  // Muted text color for descriptions
  static const Color textSecondary = Color(0xFFBFBFBF);  // Light Gray

  // ==================== BORDER COLORS ====================
  // Border color for dark mode - Dividers, card borders
  static const Color borderDark = Color(0xFF065F46);  // Muted Dark Green

  // ==================== STATUS COLORS ====================
  // Success state color - Active, approved
  static const Color statusActive = Color(0xFF10B981);  // Green
  static const Color statusSuccess = statusActive;

  // Warning state color - Pending, attention needed
  static const Color statusPending = Color(0xFFF59E0B);  // Amber
  static const Color statusWarning = statusPending;

  // Error state color - Absent, rejected
  static const Color statusAbsent = Color(0xFFEF4444);  // Red
  static const Color statusError = statusAbsent;

  // Info state color
  static const Color statusInfo = Color(0xFF3B82F6);  // Blue

  // Fonts
  static const String displayFontFamily = 'Noto Serif';  // Elegant serif for headings
  static const String bodyFontFamily = 'Noto Sans';      // Clean sans for body text

  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: mainColor,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: bodyFontFamily,
      colorScheme: const ColorScheme.dark(
        primary: mainColor,
        secondary: accentColor,
        background: backgroundDark,
        surface: backgroundCard,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onBackground: textPrimaryDark,
        onSurface: textPrimaryDark,
      ),
      dividerColor: borderDark,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: displayFontFamily),
        displayMedium: TextStyle(fontFamily: displayFontFamily),
        displaySmall: TextStyle(fontFamily: displayFontFamily),
        headlineLarge: TextStyle(fontFamily: displayFontFamily),
        headlineMedium: TextStyle(fontFamily: displayFontFamily),
        headlineSmall: TextStyle(fontFamily: displayFontFamily),
        titleLarge: TextStyle(fontFamily: displayFontFamily),
        titleMedium: TextStyle(fontFamily: bodyFontFamily),
        titleSmall: TextStyle(fontFamily: bodyFontFamily),
        bodyLarge: TextStyle(fontFamily: bodyFontFamily),
        bodyMedium: TextStyle(fontFamily: bodyFontFamily),
        bodySmall: TextStyle(fontFamily: bodyFontFamily),
      ),
    );
  }
}
```

**1.2 Create ThemeProvider**

Create `lib/UI/Theme/ThemeProvider.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Theme1.dart';
import 'Theme2.dart';
import 'Theme3.dart';

enum ThemeSelection { theme1, theme2, theme3 }

class ThemeProvider with ChangeNotifier {
  ThemeSelection _currentThemeSelection = ThemeSelection.theme1;
  late ThemeData _currentTheme;

  // Custom color overrides (for theme customization)
  Color? _customMainColor;
  Color? _customAccentColor;
  Color? _customBackgroundColor;

  ThemeProvider() {
    _currentTheme = Theme1.themeData;
    _loadThemeFromFirebase();
  }

  ThemeData get currentTheme => _currentTheme;
  ThemeSelection get currentThemeSelection => _currentThemeSelection;

  // Load theme selection from Firebase
  Future<void> _loadThemeFromFirebase() async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('ihs/settings/theme');
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        final String? themeName = snapshot.child('selected').value as String?;
        if (themeName != null) {
          setTheme(_getThemeFromString(themeName), saveToFirebase: false);
        }

        // Load custom colors if they exist
        final String? mainColorHex = snapshot.child('customColors/main').value as String?;
        final String? accentColorHex = snapshot.child('customColors/accent').value as String?;
        final String? backgroundColorHex = snapshot.child('customColors/background').value as String?;

        if (mainColorHex != null) {
          _customMainColor = Color(int.parse(mainColorHex.replaceFirst('#', '0xFF')));
        }
        if (accentColorHex != null) {
          _customAccentColor = Color(int.parse(accentColorHex.replaceFirst('#', '0xFF')));
        }
        if (backgroundColorHex != null) {
          _customBackgroundColor = Color(int.parse(backgroundColorHex.replaceFirst('#', '0xFF')));
        }
      }
    } catch (e) {
      print('Error loading theme from Firebase: $e');
    }
  }

  // Set theme (called from admin panel)
  void setTheme(ThemeSelection theme, {bool saveToFirebase = true}) {
    _currentThemeSelection = theme;

    ThemeData selectedTheme;
    switch (theme) {
      case ThemeSelection.theme1:
        selectedTheme = Theme1.themeData;
        break;
      case ThemeSelection.theme2:
        selectedTheme = Theme2.themeData;
        break;
      case ThemeSelection.theme3:
        selectedTheme = Theme3.themeData;
        break;
    }

    // Apply custom color overrides if set
    if (_customMainColor != null || _customAccentColor != null || _customBackgroundColor != null) {
      selectedTheme = _applyCustomColors(selectedTheme);
    }

    _currentTheme = selectedTheme;
    notifyListeners();

    if (saveToFirebase) {
      _saveThemeToFirebase();
    }
  }

  // Save theme selection to Firebase (so all users see it)
  Future<void> _saveThemeToFirebase() async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('ihs/settings/theme');
      await ref.set({
        'selected': _currentThemeSelection.name,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error saving theme to Firebase: $e');
    }
  }

  // Customize theme colors (admin only)
  void customizeColors({
    Color? mainColor,
    Color? accentColor,
    Color? backgroundColor,
  }) {
    _customMainColor = mainColor;
    _customAccentColor = accentColor;
    _customBackgroundColor = backgroundColor;

    setTheme(_currentThemeSelection);
    _saveCustomColorsToFirebase();
  }

  // Apply custom colors to theme
  ThemeData _applyCustomColors(ThemeData baseTheme) {
    return baseTheme.copyWith(
      primaryColor: _customMainColor ?? baseTheme.primaryColor,
      scaffoldBackgroundColor: _customBackgroundColor ?? baseTheme.scaffoldBackgroundColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: _customMainColor ?? baseTheme.colorScheme.primary,
        secondary: _customAccentColor ?? baseTheme.colorScheme.secondary,
        background: _customBackgroundColor ?? baseTheme.colorScheme.background,
      ),
    );
  }

  // Save custom colors to Firebase
  Future<void> _saveCustomColorsToFirebase() async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('ihs/settings/theme/customColors');
      await ref.set({
        'main': _customMainColor != null ? '#${_customMainColor!.value.toRadixString(16).substring(2)}' : null,
        'accent': _customAccentColor != null ? '#${_customAccentColor!.value.toRadixString(16).substring(2)}' : null,
        'background': _customBackgroundColor != null ? '#${_customBackgroundColor!.value.toRadixString(16).substring(2)}' : null,
      });
    } catch (e) {
      print('Error saving custom colors to Firebase: $e');
    }
  }

  // Helper to convert string to theme
  ThemeSelection _getThemeFromString(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'theme1':
        return ThemeSelection.theme1;
      case 'theme2':
        return ThemeSelection.theme2;
      case 'theme3':
        return ThemeSelection.theme3;
      default:
        return ThemeSelection.theme1;
    }
  }

  // Reset to default theme colors
  void resetToDefaultColors() {
    _customMainColor = null;
    _customAccentColor = null;
    _customBackgroundColor = null;
    setTheme(_currentThemeSelection);
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

### Phase 4: Admin Theme Selector (3-4 hours)

**Create theme selection UI in admin panel**

**4.1 Create Theme Selector Screen**

Create `lib/UI/AdminScreens/ThemeSettingsScreen.dart`:

````dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Theme/ThemeProvider.dart';
import '../Theme/Theme1.dart';
import '../Theme/Theme2.dart';
import '../Theme/Theme3.dart';
import '../Widgets/Buttons/PrimaryButton.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData theme = Theme.of(context);

    return6: Testing & Documentation (2-3 hours)

**Run all tests, update README.md, final review.**

**Test Checklist:**
- [ ] Admin can select themes from Theme Settings screen
- [ ] Theme applies to entire platform (all users)
- [ ] Theme selection persists in Firebase
- [ ] All 3 themes render correctly
- [ ] Color purposes are clear in code comments

**Update README.md with:**
```markdown
## Theme System

The VMS uses a unified theme system with 3 pre-made themes:

### Theme Selection
- Admins can select themes from: **Admin Panel → Settings → Theme Settings**
- Selected theme applies to **entire platform** (all users see the same theme)
- Theme selection is saved in Firebase: `/ihs/settings/theme`

### Available Themes

**Theme 1: Red/Dark**
- Main Color: #EC1313 (Red)
- Accent Color: #C91010 (Dark Red)
- Style: Authority and urgency
- Best for: Professional, serious applications

**Theme 2: Green/Light**
- Main Color: #059669 (Green)
- Accent Color: #047857 (Dark Green)
- Style: Growth and community
- Best for: Welcoming, friendly applications

**Theme 3: Gold/Dark**
- Main Color: #F4C025 (Gold)
- Accent Color: #D6A410 (Dark Gold)
- Style: Warmth and leadership
- Best for: Elegant, premium applications

### Color Purpose System

All theme files use clearly labeled color purposes:
- **Main Color**: Primary actions, buttons, highlights
- **Accent Color**: Hover states, secondary actions
- **Background Color**: Page backgrounds
- **Surface Color**: Cards, dialogs
- **Border Color**: Dividers, borders
- **Text Colors**: Primary, secondary, muted
- **Status Colors**: Success, warning, info, error

See `lib/UI/Theme/Theme1.dart` for full color documentation.

### Future Features
- Theme color customization (modify main, accent, background colors)
- Per-user theme preferences
- Dark/light mode toggle
````

**Final Commit:**

```bash
git add .
git commit -m "Phase 6 EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select Platform Theme',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a theme for the entire platform. All users will see the selected theme.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Theme 1 Card
            _buildThemeCard(
              context: context,
              themeProvider: themeProvider,
              selection: ThemeSelection.theme1,
              title: 'Theme 1: Red/Dark',
              description: 'Authority and urgency - Professional dark theme',
              mainColor: Theme1.mainColor,
              accentColor: Theme1.accentColor,
              backgroundColor: Theme1.backgroundDark,
            ),

            const SizedBox(height: 16),

            // Theme 2 Card
            _buildThemeCard(
              context: context,
              themeProvider: themeProvider,
              selection: ThemeSelection.theme2,
              title: 'Theme 2: Green/Light',
              description: 'Growth and community - Fresh light theme',
              mainColor: Theme2.mainColor,
              accentColor: Theme2.accentColor,
              backgroundColor: Theme2.backgroundLight,
            ),

            const SizedBox(height: 16),

            // Theme 3 Card
            _buildThemeCard(
              context: context,
              themeProvider: themeProvider,
              selection: ThemeSelection.theme3,
              title: 'Theme 3: Gold/Dark',
              description: 'Warmth and leadership - Elegant dark theme',
              mainColor: Theme3.mainColor,
              accentColor: Theme3.accentColor,
              backgroundColor: Theme3.backgroundDark,
            ),

            const SizedBox(height: 48),

            // Custom Colors Section (Future Feature)
            Text(
              'Custom Colors',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Customize theme colors (Coming Soon)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),

            // Placeholder for color customization
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                children: <Widget>[
                  const Icon(Icons.palette_outlined, size: 48, opacity: 0.3),
                  const SizedBox(height: 16),
                  Text(
                    'Color customization will be available in a future update',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required ThemeSelection selection,
    required String title,
    required String description,
    required Color mainColor,
    required Color accentColor,
    required Color backgroundColor,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isSelected = themeProvider.currentThemeSelection == selection;

    return GestureDetector(
      onTap: () {
        themeProvider.setTheme(selection);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title applied to entire platform'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? mainColor : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            // Color preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: mainColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // Theme info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: mainColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      _buildColorDot('Main', mainColor),
                      const SizedBox(width: 12),
                      _buildColorDot('Accent', accentColor),
                    ],
                  ),
                ],
              ),
            ),

            // Selection indicator
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? mainColor : theme.dividerColor,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
```

**4.2 Add Theme Settings to Admin Navigation**

Update `AdminSidebar.dart` and `MobileBottomNav.dart` to include link to Theme Settings.

**4.3 Commit Phase 4**

````bash
git add .
git commit -m "Phase 4 COMPLETE: Admin theme selector UI - Unified theme selection"
git push origin feature/theme-system-implementation
``Admin can select themes from Theme Settings screen
✅ Theme applies to entire platform (all users see same theme)
✅ Theme selection saves to Firebase and persists
✅ All 3 themes render correctly
✅ All screens use theme colors (no hardcoded)
✅ Color purposes clearly documented in code comments
**STOP and report progress before Phase 5.**

---

### Phase 5: Screen Updates (8-12 hours)

Update each screen one at a time to use theme system.

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
git commit -m "Phase 5 COMPLETE: All screens migrated to theme system"
git push origin feature/theme-system-implementation
````

**STOP and report progress before Phase 6.**

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
