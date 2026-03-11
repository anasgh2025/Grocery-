import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class CreateAccountPage extends StatefulWidget {
  /// Allow injecting an ApiService for testability. Defaults to a new instance.
  const CreateAccountPage({super.key, this.api});

  final ApiService? api;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final primary = Theme.of(context).primaryColor;
    final api = widget.api ?? ApiService();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Listfy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _fieldDecoration('Full Name'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: _fieldDecoration('Email Address'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: _fieldDecoration('Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _loading = true);
                            final ctx = context;
                            final name = _nameCtrl.text.trim();
                            final email = _emailCtrl.text.trim();
                            final password = _passwordCtrl.text;
                            try {
                              await api.createUser(name: name, email: email, password: password);
                              if (!mounted) return;
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(loc?.accountCreated ?? 'Account created')));
                              Navigator.of(ctx).pop();
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : Text(loc?.signUp ?? 'Sign Up', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(loc?.alreadyHaveAccount ?? 'Already have an account?', style: const TextStyle(color: Colors.black54)),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(loc?.logIn ?? 'Log In')),
                ]),
                const SizedBox(height: 8),
                Text(loc?.terms ?? 'By signing up, you agree to our terms.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black38, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
// Removed duplicate/old widget code after main build method
}
