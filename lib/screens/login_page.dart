// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../services/api_service.dart';
import '../main.dart';
import '../landing_page.dart';
import '../l10n/app_localizations.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  // Biometrics
  static const _storage = FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      // Show Face ID button if the device supports any biometric method
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return;
      final types = await _localAuth.getAvailableBiometrics();
      if (types.isEmpty) return;
      if (mounted) setState(() => _biometricAvailable = true);
    } catch (_) {}
  }

  Future<void> _signInWithBiometrics() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: loc.faceIdSubtitle,
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!ok || !mounted) { setState(() => _loading = false); return; }

      // If a token exists, restore the session directly
      final api = ApiService();
      final token = await api.readToken();
      if (!mounted) return;
      if (token != null) {
        final name = await api.readUserName();
        if (!mounted) return;
        userNameNotifier.value = name;
        // Save face_id_enabled so the preference is persisted
        await _storage.write(key: 'face_id_enabled', value: 'true');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LandingPage()),
          (route) => false,
        );
      } else {
        // No token yet — biometric passed but user needs to log in with password first
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.signInToContinue)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final loc = AppLocalizations.of(context)!;
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(
      textDirection: textDir,
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(loc.logIn, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                const Icon(Icons.lock_outline_rounded, size: 56, color: Colors.redAccent),
                const SizedBox(height: 20),
                Text(
                  loc.welcomeBack,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.signInToContinue,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: loc.emailAddress,
                          hintTextDirection: TextDirection.ltr,
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.redAccent),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return loc.enterEmail;
                          final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
                          if (!emailRegex.hasMatch(s)) return loc.enterValidEmail;
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordCtrl,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: loc.password,
                          hintTextDirection: textDir,
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.redAccent),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        obscureText: true,
                        validator: (v) => (v ?? '').length < 6 ? loc.password6chars : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                if (!(_formKey.currentState?.validate() ?? true)) return;
                                setState(() => _loading = true);
                                final ctx = context;
                                final api = ApiService();
                                try {
                                  final res = await api.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(loc.signedIn)));
                                  final token = res['token'] as String?;
                                  if (token != null) {
                                    await api.saveToken(token);
                                  }
                                  final user = res['user'] as Map<String, dynamic>?;
                                  final displayName = user != null && user['name'] != null && (user['name'] as String).isNotEmpty
                                      ? user['name'] as String
                                      : (user != null ? (user['email'] as String?) ?? loc.profile : loc.profile);
                                  if (!mounted) return;
                                  await api.saveUserName(displayName);
                                  userNameNotifier.value = displayName;
                                  // Navigate back to landing page, clearing the stack
                                  Navigator.of(ctx).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const LandingPage()),
                                    (route) => false,
                                  );
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                                  }
                                } finally {
                                  if (mounted) setState(() => _loading = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : Text(loc.signIn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),

                      // ── Forgot Password ──
                      Align(
                        alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage())),
                          child: Text(
                            loc.forgotPassword,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // ── Face ID / Biometric sign-in ──
                      if (_biometricAvailable) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _signInWithBiometrics,
                          icon: const Icon(Icons.face_rounded, color: Colors.redAccent),
                          label: Text(
                            loc.faceIdSubtitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
