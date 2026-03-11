
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/splash_screen.dart';
import 'theme.dart';
import 'l10n/app_localizations.dart';


final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(const Locale('en'));



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Before dotenv.load');
  try {
    await dotenv.load(fileName: ".env");
    print('After dotenv.load');
  } catch (e, st) {
    print('dotenv.load error:');
    print(e);
    print(st);
  }
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Oops! An error occurred.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                details.exceptionAsString(),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };
    runApp(const MyApp());
}

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Dotenv loaded!', style: TextStyle(fontSize: 32))),
      ),
    );
  }
}

// ...existing code...


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              title: 'Grocery App Landing',
              theme: AppTheme.light(),
              darkTheme: ThemeData.dark().copyWith(
                textTheme: AppTheme.light().textTheme,
              ),
              themeMode: mode,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}

