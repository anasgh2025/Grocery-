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
  void initState() {
    super.initState();
    // Dark mode is temporarily disabled.
    if (themeModeNotifier.value != ThemeMode.light) {
      themeModeNotifier.value = ThemeMode.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // 1. Change Language
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
          // 2. Dark Mode
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
                      value: false,
                      onChanged: null,
                    ),
                  );
                },
              ),
            ),
          ),
          // 3. Share with Friends
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
          // 4. About Us
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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => SafeArea(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Drag handle ──
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // ── Title ──
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.redAccent, size: 24),
                                SizedBox(width: 10),
                                Text(
                                  'Grovia',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // ── Description ──
                            Text(
                              loc.aboutUsContent,
                              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            // ── Contact ──
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(Icons.phone_outlined, size: 16, color: Colors.redAccent),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    loc.contactDetails,
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            // ── Version + Copyright ──
                            const Text(
                              'Version 1.0.0',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const Text(
                              '© 2026 Grovia',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            // ── Close button ──
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(loc.close, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
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
