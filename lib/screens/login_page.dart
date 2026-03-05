import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'profile_landing_page.dart';
import '../l10n/app_localizations.dart';

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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final primary = Theme.of(context).colorScheme.primary;
  final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(loc.logIn),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(loc.welcomeBack, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(loc.signInToContinue, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(hintText: loc.emailAddress, filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return loc.enterEmail;
                        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
                        if (!emailRegex.hasMatch(s)) return loc.enterValidEmail;
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: InputDecoration(hintText: loc.password, filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      obscureText: true,
                      validator: (v) => (v ?? '').length < 6 ? loc.password6chars : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              if (!(_formKey.currentState?.validate() ?? true)) return;
                              setState(() => _loading = true);
                              final ctx = context; // capture context before awaiting
                              final api = ApiService();
                              try {
                                final res = await api.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
                                if (!mounted) return;
                                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(loc.signedIn)));
                                // Persist token and navigate to the profile landing page.
                                final token = res['token'] as String?;
                                if (token != null) {
                                  await api.saveToken(token);
                                }
                                final user = res['user'] as Map<String, dynamic>?;
                                final displayName = user != null && user['name'] != null && (user['name'] as String).isNotEmpty
                                    ? user['name'] as String
                                    : (user != null ? (user['email'] as String?) ?? loc.profile : loc.profile);
                                if (!mounted) return;
                                Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (context) => ProfileLandingPage(name: displayName)));
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                                }
                              } finally {
                                if (mounted) setState(() => _loading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Text(loc.signIn),
                    ),
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
