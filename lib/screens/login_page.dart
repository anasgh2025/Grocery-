import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'profile_landing_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    return Scaffold(
      appBar: AppBar(
        // Use a simple back pop to return to previous page.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Log In'),
        // Use theme defaults so the back button is visible on both light/dark themes.
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text('Welcome back', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Sign in to continue to ShopSmart', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(hintText: 'Email', filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: InputDecoration(hintText: 'Password', filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        final ctx = context; // capture context before awaiting
                        final api = ApiService();
                        try {
                          final res = await api.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Signed in')));
                          // Persist token and navigate to the profile landing page.
                          final token = res['token'] as String?;
                          if (token != null) {
                            await api.saveToken(token);
                          }
                          final user = res['user'] as Map<String, dynamic>?;
                          final displayName = user != null && user['name'] != null && (user['name'] as String).isNotEmpty
                              ? user['name'] as String
                              : (user != null ? (user['email'] as String?) ?? 'Profile' : 'Profile');
                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (context) => ProfileLandingPage(name: displayName)));
                        } catch (e) {
                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
