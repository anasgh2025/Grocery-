import 'package:flutter/material.dart';

import 'landing_page.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nunito font is now loaded locally via assets/fonts and registered in pubspec.yaml.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery App Landing',
      theme: AppTheme.light(),
  home: SplashScreen(),
    );
  }
}

