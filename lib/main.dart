import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing_page.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-load Inter so font metrics are stable before the first frame is drawn.
  // Without this, async font loading mid-render causes layout shifts → card jitter.
  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery App Landing',
      theme: AppTheme.light(),
      home: const LandingPage(),
    );
  }
}

