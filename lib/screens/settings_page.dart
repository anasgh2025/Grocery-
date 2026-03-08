// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = localeNotifier.value?.languageCode ?? 'en';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Material(
              color: Colors.white,
              elevation: 0.5,
              borderRadius: BorderRadius.circular(14),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: const Icon(Icons.language, color: Colors.redAccent, size: 28),
                title: Text(loc.changeLanguage, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                          value: 'en',
                          groupValue: _selectedLanguage,
                          onChanged: (val) {
                            setState(() => _selectedLanguage = val!);
                            localeNotifier.value = const Locale('en');
                          },
                        ),
                        Text(loc.english),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'ar',
                          groupValue: _selectedLanguage,
                          onChanged: (val) {
                            setState(() => _selectedLanguage = val!);
                            localeNotifier.value = const Locale('ar');
                          },
                        ),
                        Text(loc.arabic),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Material(
              color: Colors.white,
              elevation: 0.5,
              borderRadius: BorderRadius.circular(14),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: const Icon(Icons.info_outline, color: Colors.redAccent, size: 28),
                title: Text(loc.aboutUs, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: loc.appTitle,
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 ShopSmart',
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(loc.aboutUsContent),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Material(
              color: Colors.white,
              elevation: 0.5,
              borderRadius: BorderRadius.circular(14),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: const Icon(Icons.share, color: Colors.redAccent, size: 28),
                title: Text(loc.shareApp, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Share.share('Check out ShopSmart Grocery App! Download now: https://shopsmart.app');
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Material(
              color: Colors.white,
              elevation: 0.5,
              borderRadius: BorderRadius.circular(14),
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeModeNotifier,
                builder: (context, mode, _) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: const Icon(Icons.brightness_6_outlined, color: Colors.redAccent, size: 28),
                    title: Text(loc.theme, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Switch(
                      value: mode == ThemeMode.dark,
                      onChanged: (val) {
                        themeModeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
