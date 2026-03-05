import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LandingPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ShopSmart',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 32,
                color: const Color(0xFF1A1C1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ELEVATE YOUR GROCERY EXPERIENCE',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.blueGrey.shade900.withOpacity(0.7),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
            ),
          ],
        ),
      ),
    );
  }
}
