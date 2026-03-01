import 'package:flutter/material.dart';
import '../screens/profile_landing_page.dart';
import '../landing_page.dart';

/// Footer menu (BottomAppBar) separated for clarity
class FooterMenu extends StatelessWidget {
  const FooterMenu({super.key, required this.accent, this.height});

  final Color accent;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: height ?? 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LandingPage()),
                (route) => false,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, color: accent, size: 26),
                const SizedBox(height: 2),
                Text('Home', style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // Categories button removed
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileLandingPage()));
            },
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, color: accent, size: 26),
                const SizedBox(height: 2),
                Text('Profile', style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}
