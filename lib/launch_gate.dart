import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding_page.dart';
import 'screens/splash_screen.dart';

class LaunchGate extends StatefulWidget {
  const LaunchGate({Key? key}) : super(key: key);

  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> {
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenOnboarding') ?? false;
    setState(() => _showOnboarding = !seen);
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _showOnboarding!
        ? const OnboardingPage()
        : const SplashScreen();
  }
}
