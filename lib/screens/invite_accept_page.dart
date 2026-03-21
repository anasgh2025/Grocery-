// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../screens/login_page.dart';
import '../landing_page.dart';

class InviteAcceptPage extends StatefulWidget {
  final String token;
  const InviteAcceptPage({super.key, required this.token});

  @override
  State<InviteAcceptPage> createState() => _InviteAcceptPageState();
}

class _InviteAcceptPageState extends State<InviteAcceptPage> {
  final _api = ApiService();

  // Preview data fetched from the server
  bool _previewLoading = true;
  String? _previewError;
  String _listName = '';
  String _invitedBy = '';
  int _itemCount = 0;

  // Action state
  bool _actioning = false;
  String? _actionType; // 'accept' | 'reject'

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final data = await _api.fetchInvitePreview(widget.token);
      if (!mounted) return;
      setState(() {
        _listName = data['listName'] as String? ?? '';
        _invitedBy = data['invitedBy'] as String? ?? '';
        _itemCount = (data['itemCount'] as num?)?.toInt() ?? 0;
        _previewLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _previewError = e.toString();
        _previewLoading = false;
      });
    }
  }

  Future<void> _onAccept(AppLocalizations loc) async {
    // Guard: must be logged in
    final loggedIn = await _api.isLoggedIn;
    if (!loggedIn) {
      // Push LoginPage with a callback — on success it pops back here
      // and we automatically proceed with accepting the invite.
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginPage(
            onLoginSuccess: () => _onAccept(loc),
          ),
        ),
      );
      return;
    }

    setState(() { _actioning = true; _actionType = 'accept'; });
    try {
      await _api.acceptInvite(inviteToken: widget.token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.inviteAccepted),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to home so the shared list appears
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
      setState(() { _actioning = false; _actionType = null; });
    }
  }

  Future<void> _onReject(AppLocalizations loc) async {
    final loggedIn = await _api.isLoggedIn;
    setState(() { _actioning = true; _actionType = 'reject'; });
    try {
      if (loggedIn) {
        await _api.rejectInvite(inviteToken: widget.token);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.inviteDeclined)),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      setState(() { _actioning = false; _actionType = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final primary = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          title: Text(loc.acceptInvite, style: const TextStyle(color: Colors.white)),
        ),
        body: SafeArea(
          child: _previewLoading
              ? const Center(child: CircularProgressIndicator())
              : _previewError != null
                  ? _buildError(loc)
                  : _buildPreview(loc, primary),
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              loc.inviteInvalid,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(AppLocalizations loc, Color primary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Icon
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.group_add_rounded, size: 48, color: primary),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            loc.inviteTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle — who invited you
          Text(
            loc.inviteSubtitle(_invitedBy.isNotEmpty ? _invitedBy : '…'),
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // List preview card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_cart_rounded, color: primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _listName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.checklist_rounded, color: Colors.black38, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      loc.inviteItemCount(_itemCount),
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Accept button
          ElevatedButton(
            onPressed: _actioning ? null : () => _onAccept(loc),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _actioning && _actionType == 'accept'
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(loc.acceptInvite, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),

          // Reject button
          OutlinedButton(
            onPressed: _actioning ? null : () => _onReject(loc),
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: BorderSide(color: primary),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _actioning && _actionType == 'reject'
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                  )
                : Text(loc.rejectInvite, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
