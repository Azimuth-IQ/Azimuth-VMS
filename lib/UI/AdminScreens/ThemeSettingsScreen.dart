import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Theme/ThemeProvider.dart';
import '../Theme/Theme1.dart';
import '../Theme/Theme2.dart';
import '../Theme/Theme3.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings'), backgroundColor: theme.colorScheme.surface),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Select Platform Theme', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Choose a theme for the entire platform. All users will see the selected theme.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
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
            Text('Custom Colors', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text('Customize theme colors (Coming Soon)', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7))),
            const SizedBox(height: 16),

            // Placeholder for color customization
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
              child: Column(
                children: <Widget>[
                  Icon(Icons.palette_outlined, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Color customization will be available in a future update',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.5)),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title applied to entire platform'), duration: const Duration(seconds: 2)));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? mainColor : theme.dividerColor, width: isSelected ? 2 : 1),
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
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: mainColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
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
                      Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: mainColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            'ACTIVE',
                            style: TextStyle(color: mainColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.6))),
                  const SizedBox(height: 8),
                  Row(children: <Widget>[_buildColorDot('Main', mainColor), const SizedBox(width: 12), _buildColorDot('Accent', accentColor)]),
                ],
              ),
            ),

            // Selection indicator
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? mainColor : theme.dividerColor, size: 28),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
