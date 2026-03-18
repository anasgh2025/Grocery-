import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../landing_page.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_dialog.dart';
import 'login_page.dart';
import 'create_account_page.dart';

/// Profile page — logged-in view has Change Password, Face ID, Delete Account, Sign Out.
class ProfileLandingPage extends StatefulWidget {
  const ProfileLandingPage({super.key, this.name});
  final String? name;

  @override
  State<ProfileLandingPage> createState() => _ProfileLandingPageState();
}

class _ProfileLandingPageState extends State<ProfileLandingPage> {
  static const _faceIdKey = 'face_id_enabled';

  final ApiService _api = ApiService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool _loading = true;
  String? _displayName;
  bool _faceIdEnabled = false;
  bool _faceIdAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await _api.isLoggedIn;
    String? name = widget.name?.isNotEmpty == true ? widget.name : null;
    name ??= userNameNotifier.value?.isNotEmpty == true ? userNameNotifier.value : null;
    name ??= await _api.readUserName();

    bool canCheck = false;
    try {
      canCheck = await _localAuth.canCheckBiometrics;
      if (canCheck) {
        final types = await _localAuth.getAvailableBiometrics();
        canCheck = types.isNotEmpty;
      }
    } catch (_) {}

    final savedFaceId = await _storage.read(key: _faceIdKey);
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _displayName = name;
        _faceIdAvailable = canCheck;
        _faceIdEnabled = savedFaceId == 'true';
        _loading = false;
      });
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────
  Future<void> _signOut() async {
    try { await _api.clearToken(); } catch (_) {}
    userNameNotifier.value = null;
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingPage()), (route) => false);
  }

  // ── Face ID toggle ────────────────────────────────────────────────────────
  Future<void> _toggleFaceId(bool value) async {
    if (value) {
      try {
        final loc = AppLocalizations.of(context)!;
        final ok = await _localAuth.authenticate(
          localizedReason: loc.faceIdSubtitle,
          options: const AuthenticationOptions(biometricOnly: true),
        );
        if (!ok) return;
      } catch (_) { return; }
    }
    await _storage.write(key: _faceIdKey, value: value.toString());
    if (mounted) setState(() => _faceIdEnabled = value);
  }

  // ── Change password ───────────────────────────────────────────────────────
  void _showChangePasswordSheet() {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final primary = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String? errorMsg;
        bool saving = false;
        bool showCurrent = false, showNew = false, showConfirm = false;

        return StatefulBuilder(builder: (ctx, setSheet) {
          return Directionality(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: Container(width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                    Text(loc.changePassword,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    _pwField(loc.currentPassword, currentCtrl, showCurrent,
                      () => setSheet(() => showCurrent = !showCurrent)),
                    const SizedBox(height: 12),
                    _pwField(loc.newPassword, newCtrl, showNew,
                      () => setSheet(() => showNew = !showNew)),
                    const SizedBox(height: 12),
                    _pwField(loc.confirmNewPassword, confirmCtrl, showConfirm,
                      () => setSheet(() => showConfirm = !showConfirm)),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 8),
                      Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: saving ? null : () async {
                        if (newCtrl.text != confirmCtrl.text) {
                          setSheet(() => errorMsg = loc.passwordsDontMatch);
                          return;
                        }
                        setSheet(() { saving = true; errorMsg = null; });
                        try {
                          await _api.changePassword(
                            currentPassword: currentCtrl.text,
                            newPassword: newCtrl.text,
                          );
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.passwordChanged)));
                          }
                        } catch (e) {
                          final msg = e.toString().contains('incorrect')
                              ? loc.wrongCurrentPassword
                              : e.toString().replaceFirst('Exception: ', '');
                          setSheet(() { saving = false; errorMsg = msg; });
                        }
                      },
                      child: saving
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(loc.changePassword),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _pwField(String label, TextEditingController ctrl, bool visible, VoidCallback toggleVis) {
    return TextField(
      controller: ctrl, obscureText: !visible, textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: label, filled: true, fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVis,
        ),
      ),
    );
  }

  // ── Delete account ────────────────────────────────────────────────────────
  Future<void> _confirmDeleteAccount() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: Text(loc.deleteAccount,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
      content: Text(loc.deleteAccountConfirm),
      actions: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          appDialogCancelButton(onPressed: () => Navigator.of(context).pop(false), text: loc.cancel),
          const SizedBox(width: 12),
          appDialogConfirmButton(
            onPressed: () => Navigator.of(context).pop(true),
            text: loc.deleteAccount, color: Colors.red),
        ]),
      ],
    );
    if (confirmed != true || !mounted) return;
    try {
      await _api.deleteAccount();
      await _api.clearToken();
      userNameNotifier.value = null;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.accountDeleted)));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingPage()), (route) => false);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(loc.profile,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _isLoggedIn
                  ? _buildLoggedInView(loc, primary)
                  : _buildLoggedOutView(context, loc, primary),
        ),
      ),
    );
  }

  Widget _buildLoggedInView(AppLocalizations loc, Color primary) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        // ── Avatar + name ──
        Center(child: Column(children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: primary.withAlpha(30),
            child: Icon(Icons.person_rounded, size: 48, color: primary),
          ),
          const SizedBox(height: 12),
          Text(
            _displayName?.isNotEmpty == true ? _displayName! : loc.profile,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
          ),
          const SizedBox(height: 4),
          Text(loc.welcomeToProfile,
            style: const TextStyle(fontSize: 13, color: Colors.black45)),
        ])),
        const SizedBox(height: 32),

        // ── Account settings card ──
        _SettingsCard(children: [
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            iconColor: primary,
            title: loc.changePassword,
            onTap: _showChangePasswordSheet,
          ),
          if (_faceIdAvailable) ...[
            const Divider(height: 1, indent: 56),
            _SettingsTileSwitch(
              icon: Icons.face_rounded,
              iconColor: primary,
              title: loc.faceId,
              subtitle: loc.faceIdSubtitle,
              value: _faceIdEnabled,
              onChanged: _toggleFaceId,
            ),
          ],
        ]),
        const SizedBox(height: 16),

        // ── Danger zone ──
        _SettingsCard(children: [
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            iconColor: Colors.red,
            titleColor: Colors.red,
            title: loc.deleteAccount,
            onTap: _confirmDeleteAccount,
          ),
        ]),
        const SizedBox(height: 16),

        // ── Sign out ──
        OutlinedButton.icon(
          icon: const Icon(Icons.logout_rounded),
          label: Text(loc.signOut),
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: BorderSide(color: primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _signOut,
        ),
      ],
    );
  }

  Widget _buildLoggedOutView(BuildContext context, AppLocalizations loc, Color primary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.person_outline, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(loc.notSignedIn,
            style: TextStyle(color: primary, fontSize: 22, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(loc.logInOrCreate,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 14)),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginPage())),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(loc.logIn))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateAccountPage())),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary, side: BorderSide(color: primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(loc.createAccount))),
        ]),
      ),
    );
  }
}

// ── Reusable settings widgets ──────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: children),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon, required this.iconColor,
    required this.title, required this.onTap, this.titleColor,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: iconColor.withAlpha(20), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor, size: 20),
    ),
    title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: titleColor)),
    trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
    onTap: onTap,
  );
}

class _SettingsTileSwitch extends StatelessWidget {
  const _SettingsTileSwitch({
    required this.icon, required this.iconColor, required this.title,
    required this.subtitle, required this.value, required this.onChanged,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: iconColor.withAlpha(20), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor, size: 20),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black45)),
    trailing: Switch(value: value, onChanged: onChanged, activeColor: iconColor),
  );
}
