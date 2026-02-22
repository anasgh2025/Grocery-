import 'package:flutter/material.dart';
import 'create_account_page.dart';
import 'login_page.dart';

class ProfileLandingPage extends StatelessWidget {
  const ProfileLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        // simple back button to return to previous screen
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo / title
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // subtle rounded accent behind the text
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 64,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Text(
                      'shopping_basket',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primary,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Text('Join ShopSmart', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'The smartest way to manage your\ngroceries.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),

                const SizedBox(height: 28),

                // Google button (outlined)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: Colors.black12),
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.account_circle, color: Colors.redAccent),
                    label: const Text('Continue with Google'),
                    onPressed: () {},
                  ),
                ),

                const SizedBox(height: 12),

                // Apple button (black)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.apple),
                    label: const Text('Continue with Apple'),
                    onPressed: () {},
                  ),
                ),

                const SizedBox(height: 12),

                // OR divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR', style: TextStyle(color: Colors.black45)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 12),

                // Sign up with Email (primary)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateAccountPage()));
                    },
                    child: const Text('Sign up with Email'),
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?', style: TextStyle(color: Colors.black54)),
                    TextButton(onPressed: () { Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage())); }, child: Text('Log In', style: TextStyle(color: primary))),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'By signing up, you agree to our TERMS OF SERVICE and PRIVACY POLICY',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
