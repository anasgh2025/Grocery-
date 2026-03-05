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
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
  final primary = Theme.of(context).colorScheme.primary;
  final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: Text(loc.createAccount),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(loc.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _fieldDecoration(loc.nameHint),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v ?? '').trim().isEmpty ? loc.enterFullName : null,
                    ),

                    const SizedBox(height: 12),
                    Text(loc.emailAddress, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration(loc.emailHint),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return loc.enterEmail;
                        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
                        if (!emailRegex.hasMatch(s)) return loc.enterValidEmail;
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),
                    Text(loc.password, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: _fieldDecoration(loc.passwordHint),
                      textInputAction: TextInputAction.done,
                      validator: (v) => (v ?? '').length < 6 ? loc.password6chars : null,
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.black45),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(loc.orJoinWith, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 14),

              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, color: Colors.redAccent),
                    label: Text(loc.google),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.apple),
                    label: Text(loc.apple),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ]),

              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? true)) return;
                        setState(() => _loading = true);
                        final ctx = context; // capture context before async gap
                        final name = _nameCtrl.text.trim();
                        final email = _emailCtrl.text.trim();
                        final password = _passwordCtrl.text;
                        final api = widget.api ?? ApiService();
                        try {
                          await api.createUser(name: name, email: email, password: password);
                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(loc.accountCreated)));
                          // ignore: use_build_context_synchronously
                          Navigator.of(ctx).pop();
                        } catch (e) {
                            if (mounted) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4),
                child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Text(loc.signUp, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),

              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(loc.alreadyHaveAccount, style: const TextStyle(color: Colors.black54)),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(loc.logIn)),
              ]),

              const SizedBox(height: 8),
              Text(loc.terms, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black38, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
