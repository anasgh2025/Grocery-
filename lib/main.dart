
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';

import 'launch_gate.dart';
import 'screens/invite_accept_page.dart';
import 'screens/reset_password_page.dart';
import 'theme.dart';
import 'l10n/app_localizations.dart';


final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(const Locale('en'));
/// Holds the logged-in user's display name; null when signed out.
final ValueNotifier<String?> userNameNotifier = ValueNotifier<String?>(null);



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


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  // Track the last handled URI to prevent duplicate pushes (iOS re-fires
  // the deep link when the keyboard appears after a cold-start open).
  String? _lastHandledUri;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle link that launched the app from cold start.
    // Retry until the navigator is mounted (LaunchGate may still be loading).
    _appLinks.getInitialAppLink().then((uri) {
      if (uri != null) _handleLinkWhenReady(uri);
    }).catchError((e) {
      print('getInitialAppLink error: $e');
    });

    // Handle links while the app is already running
    _appLinks.uriLinkStream.listen(
      (uri) {
        try {
          _handleLink(uri);
        } catch (e, st) {
          print('Deep link handler error: $e\n$st');
        }
      },
      onError: (e) => print('Deep link stream error: $e'),
    );
  }

  /// Retries pushing the link every 100 ms until the navigator is available.
  void _handleLinkWhenReady(Uri uri, [int attempts = 0]) {
    try {
      if (_navigatorKey.currentState != null) {
        _handleLink(uri);
      } else if (attempts < 30) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _handleLinkWhenReady(uri, attempts + 1);
        });
      }
    } catch (e, st) {
      print('_handleLinkWhenReady error: $e\n$st');
    }
  }

  void _handleLink(Uri uri) {
    print('[DeepLink] received: $uri  host=${uri.host}  path=${uri.path}  segments=${uri.pathSegments}');

    // Deduplicate: iOS can re-fire the same deep link when the keyboard opens.
    final uriStr = uri.toString();
    if (uriStr == _lastHandledUri) {
      print('[DeepLink] duplicate, ignoring.');
      return;
    }
    _lastHandledUri = uriStr;

    final nav = _navigatorKey.currentState;
    if (nav == null) {
      print('[DeepLink] navigator not ready, dropping: $uri');
      return;
    }

    // grovia://invite/<token>
    if (uri.host == 'invite' && uri.pathSegments.isNotEmpty) {
      final token = uri.pathSegments.first;
      nav.push(MaterialPageRoute(builder: (_) => InviteAcceptPage(token: token)));
      return;
    }

    // grovia://reset-password/<token>
    // uri.host == 'reset-password', token is first path segment
    if (uri.host == 'reset-password' && uri.pathSegments.isNotEmpty) {
      final token = uri.pathSegments.first;
      nav.push(MaterialPageRoute(builder: (_) => ResetPasswordPage(token: token)));
      return;
    }

    print('[DeepLink] unrecognised URI, ignoring: $uri');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'Grocery App Landing',
              theme: AppTheme.light(),
              darkTheme: ThemeData.dark().copyWith(
                textTheme: AppTheme.light().textTheme,
              ),
              themeMode: mode,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const LaunchGate(),
            );
          },
        );
      },
    );
  }
}

