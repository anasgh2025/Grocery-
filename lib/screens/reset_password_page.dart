// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.token});
  final String token;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showNew = false;
  bool _showConfirm = false;
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _errorMsg = loc.passwordsDontMatch);
      return;
    }
    if (_newCtrl.text.length < 6) {
      setState(() => _errorMsg = loc.password6chars);
      return;
    }
    setState(() { _loading = true; _errorMsg = null; });
    try {
      await ApiService().resetPassword(
        token: widget.token,
        newPassword: _newCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.resetPasswordSuccess)));
    } catch (e) {
      final msg = e.toString().contains('invalid') || e.toString().contains('expired')
          ? AppLocalizations.of(context)!.invalidResetLink
          : e.toString().replaceFirst('Exception: ', '');
      if (mounted) setState(() { _loading = false; _errorMsg = msg; });
    }
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
          title: Text(loc.resetPassword,
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 56, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  Text(
                    loc.resetPassword,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  _pwField(loc.newPassword, _newCtrl, _showNew,
                      () => setState(() => _showNew = !_showNew)),
                  const SizedBox(height: 14),
                  _pwField(loc.confirmNewPassword, _confirmCtrl, _showConfirm,
                      () => setState(() => _showConfirm = !_showConfirm)),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 10),
                    Text(_errorMsg!,
                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white)))
                        : Text(loc.resetPassword,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pwField(String hint, TextEditingController ctrl, bool visible,
      VoidCallback toggleVis) {
    return TextField(
      controller: ctrl,
      obscureText: !visible,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon:
            const Icon(Icons.lock_outline, color: Colors.redAccent),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(
            visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.redAccent,
          ),
          onPressed: toggleVis,
        ),
      ),
    );
  }
}
