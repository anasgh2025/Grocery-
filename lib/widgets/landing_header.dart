import 'package:flutter/material.dart';
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
          // Left: Logo (30%)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 36,
                  height: 36,
                  semanticLabel: 'logo',
                ),
              ),
            ),
          ),
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
                IconButton(
                  icon: const Icon(Icons.language, color: Color(0xFF1A1C1E)),
                  onPressed: () {},
                  tooltip: 'Change Language',
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
