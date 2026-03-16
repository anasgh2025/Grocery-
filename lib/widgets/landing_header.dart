import 'package:flutter/material.dart';
import '../main.dart';
// Using bundled Nunito font from assets (configured in pubspec.yaml)

/// Header: logo, avatar and search field
class LandingHeader extends StatelessWidget {
  const LandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      color: const Color(0xFFF9FAFB),
      child: Row(
        children: [
          // Left: (Logo removed)
          // Right: Notification and Language icons (70%)
          Expanded(
            flex: 7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1A1C1E)),
                  onPressed: () {},
                  tooltip: 'Notifications',
                ),
                // Language toggle button
                ValueListenableBuilder<Locale?>(
                  valueListenable: localeNotifier,
                  builder: (context, locale, _) {
                    final isArabic = locale?.languageCode == 'ar';
                    return GestureDetector(
                      onTap: () {
                        localeNotifier.value =
                            isArabic ? const Locale('en') : const Locale('ar');
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isArabic ? 'AR' : 'EN',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
