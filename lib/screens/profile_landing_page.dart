import 'package:flutter/material.dart';
import '../widgets/footer_menu.dart';
import '../landing_page.dart';
import '../services/api_service.dart';

/// A minimal profile landing page. Accepts an optional [name] so callers
/// (like the login flow) can show the signed-in user's display name.
class ProfileLandingPage extends StatelessWidget {
  const ProfileLandingPage({super.key, this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name != null && name!.isNotEmpty ? name! : 'Profile',
                  style: TextStyle(color: primary, fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome to your profile',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Clear persisted auth token and return to landing page.
                      try {
                        await ApiService().clearToken();
                      } catch (_) {
                        // ignore storage errors and continue navigation
                      }
                      // Remove all previous routes and show landing page.
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (ctx) => const LandingPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FooterMenu(accent: primary),
    );
  }
}
