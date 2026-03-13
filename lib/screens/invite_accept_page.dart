
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/grocery_list.dart';

class InviteAcceptPage extends StatefulWidget {
  final String token;
  const InviteAcceptPage({Key? key, required this.token}) : super(key: key);

  @override
  State<InviteAcceptPage> createState() => _InviteAcceptPageState();
}

class _InviteAcceptPageState extends State<InviteAcceptPage> {
  bool _loading = false;
  String? _error;
  bool _success = false;

  Future<void> _acceptInvite() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // TODO: Replace with real userId from auth/user profile
      final userId = await _getUserId();
      final api = ApiService();
      final result = await api.acceptInvite(token: widget.token, userId: userId);
      setState(() {
        _success = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite accepted! You can now access the shared list.')),
      );
      // Optionally, fetch the list and navigate to its details page
      final listId = result['listId'] as String?;
      if (listId != null) {
        final list = await api.fetchGroceryListById(listId);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _ListDetailsPageForInvite(list: list),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept invite: $e')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Dummy userId fetcher (replace with real auth integration)
  Future<String> _getUserId() async {
    // TODO: Integrate with real user profile/auth
    // For now, use a placeholder or device id
    return 'demo-user';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accept Invite'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.group_add, size: 64, color: Colors.redAccent),
              const SizedBox(height: 24),
              const Text(
                'You have been invited to join a grocery list!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Invite code: ${widget.token}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
                label: Text(_loading ? 'Accepting...' : 'Accept Invite'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loading || _success ? null : _acceptInvite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder for navigation after invite acceptance
class _ListDetailsPageForInvite extends StatelessWidget {
  final GroceryList list;
  const _ListDetailsPageForInvite({required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(list.name)),
      body: Center(child: Text('Welcome to the shared list: ${list.name}')),
    );
  }
}
