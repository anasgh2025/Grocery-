import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../screens/profile_landing_page.dart';

/// Header: profile avatar (left), notification + language toggle (right)
class LandingHeader extends StatefulWidget {
  const LandingHeader({super.key});

  @override
  State<LandingHeader> createState() => _LandingHeaderState();
}

class _LandingHeaderState extends State<LandingHeader> {
  @override
  void initState() {
    super.initState();
    // Restore persisted user name on cold start so avatar shows immediately
    _restoreUserName();
  }

  Future<void> _restoreUserName() async {
    if (userNameNotifier.value != null) return; // already set (e.g. just logged in)
    final name = await ApiService().readUserName();
    if (mounted && name != null && name.isNotEmpty) {
      userNameNotifier.value = name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      color: const Color(0xFFF9FAFB),
      child: Row(
        children: [
          // ── Left: profile avatar ─────────────────────────────────
          ValueListenableBuilder<String?>(
            valueListenable: userNameNotifier,
            builder: (context, userName, _) {
              final isLoggedIn = userName != null && userName.isNotEmpty;
              final initial = isLoggedIn ? userName.trim()[0].toUpperCase() : null;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileLandingPage(name: userName),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isLoggedIn ? Colors.redAccent : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isLoggedIn
                        ? Text(
                            initial!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                  ),
                ),
              );
            },
          ),

          // ── Right: notification + language toggle ────────────────
          Expanded(
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
