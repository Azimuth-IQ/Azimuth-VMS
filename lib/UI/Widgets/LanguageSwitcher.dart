import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:azimuth_vms/Providers/LanguageProvider.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showLabel;
  final bool isIconButton;

  const LanguageSwitcher({Key? key, this.showLabel = true, this.isIconButton = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (isIconButton) {
      return IconButton(icon: const Icon(Icons.language), tooltip: l10n.switchLanguage, onPressed: () => _showLanguageDialog(context));
    }

    return PopupMenuButton<Locale>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, size: 20),
          if (showLabel) ...[const SizedBox(width: 8), Text(languageProvider.isEnglish ? 'English' : 'العربية', style: const TextStyle(fontSize: 14))],
        ],
      ),
      onSelected: (Locale locale) async {
        await languageProvider.setLocale(locale);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.languageChanged), duration: const Duration(seconds: 2)));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Row(
            children: [
              if (languageProvider.isEnglish) const Icon(Icons.check, size: 20, color: Colors.blue),
              if (languageProvider.isEnglish) const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('ar'),
          child: Row(
            children: [
              if (languageProvider.isArabic) const Icon(Icons.check, size: 20, color: Colors.blue),
              if (languageProvider.isArabic) const SizedBox(width: 8),
              const Text('العربية'),
            ],
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: languageProvider.currentLocale,
                onChanged: (Locale? value) async {
                  if (value != null) {
                    await languageProvider.setLocale(value);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.languageChanged)));
                    }
                  }
                },
              ),
              RadioListTile<Locale>(
                title: const Text('العربية'),
                value: const Locale('ar'),
                groupValue: languageProvider.currentLocale,
                onChanged: (Locale? value) async {
                  if (value != null) {
                    await languageProvider.setLocale(value);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.languageChanged)));
                    }
                  }
                },
              ),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))],
        );
      },
    );
  }
}
