import 'package:flutter/material.dart';
import '../landing_page.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import 'login_page.dart';
import 'create_account_page.dart';

/// Profile page that adapts based on authentication state.
/// - Logged in: shows user name + Sign Out button.
/// - Logged out: shows Log In / Create Account options.
class ProfileLandingPage extends StatefulWidget {
  const ProfileLandingPage({super.key, this.name});

  final String? name;

  @override
  State<ProfileLandingPage> createState() => _ProfileLandingPageState();
}

class _ProfileLandingPageState extends State<ProfileLandingPage> {
  final ApiService _api = ApiService();
  bool _isLoggedIn = false;
  bool _loading = true;
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await _api.isLoggedIn;
    // Prefer name from widget prop, then global notifier, then secure storage
    String? name = widget.name?.isNotEmpty == true ? widget.name : null;
    name ??= userNameNotifier.value?.isNotEmpty == true ? userNameNotifier.value : null;
    name ??= await _api.readUserName();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _displayName = name;
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _api.clearToken();
    } catch (_) {}
    // Clear the global user name so the header avatar disappears
    userNameNotifier.value = null;
    if (!mounted) return;
    // Navigate to a fresh LandingPage, clearing all routes so data refreshes.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _isLoggedIn
                      ? _buildLoggedInView(context, loc, primary)
                      : _buildLoggedOutView(context, loc, primary),
                ),
              ),
      ),
    ),
    );
  }

  /// Shown when the user has a valid auth token.
  Widget _buildLoggedInView(BuildContext context, AppLocalizations loc, Color primary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.account_circle, size: 72, color: primary),
        const SizedBox(height: 16),
        Text(
          _displayName != null && _displayName!.isNotEmpty ? _displayName! : loc.profile,
          style: TextStyle(color: primary, fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          loc.welcomeToProfile,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(loc.signOut),
          ),
        ),
      ],
    );
  }

  /// Shown when no auth token is present.
  Widget _buildLoggedOutView(BuildContext context, AppLocalizations loc, Color primary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.person_outline, size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          loc.notSignedIn,
          style: TextStyle(color: primary, fontSize: 22, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          loc.logInOrCreate,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(loc.logIn),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateAccountPage()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: BorderSide(color: primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(loc.createAccount),
          ),
        ),
      ],
    );
  }
}
