import 'package:flutter/material.dart';

import 'landing_page.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';


final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(const Locale('en'));


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nunito font is now loaded locally via assets/fonts and registered in pubspec.yaml.
  runApp(MyApp());
}


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

