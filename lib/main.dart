
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  static const _channel = MethodChannel('grovia/deep_links');
  String? _lastHandledUri;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // Listen for URLs while the app is already running (foreground/background).
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onUrl') {
        final url = call.arguments as String?;
        if (url != null) _handleLink(Uri.parse(url));
      }
    });

    // Get the URL that cold-started the app (if any).
    // Retry until the navigator is mounted.
    _channel.invokeMethod<String>('getInitialUrl').then((url) {
      if (url != null) {
        _handleLinkWhenReady(Uri.parse(url), replaceStack: true);
      }
    }).catchError((e) {
      print('[DeepLink] getInitialUrl error: $e');
    });
  }

  /// Retries every 100 ms until the navigator is mounted (max 3 seconds).
  void _handleLinkWhenReady(
    Uri uri, {
    bool replaceStack = false,
    int attempts = 0,
  }) {
    if (_navigatorKey.currentState != null) {
      _handleLink(uri, replaceStack: replaceStack);
    } else if (attempts < 30) {
      Future.delayed(const Duration(milliseconds: 100),
          () => _handleLinkWhenReady(
                uri,
                replaceStack: replaceStack,
                attempts: attempts + 1,
              ));
    }
  }

  void _handleLink(Uri uri, {bool replaceStack = false}) {
    print('[DeepLink] received: $uri');

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

    void openPage(Widget page) {
      final route = MaterialPageRoute(builder: (_) => page);
      if (replaceStack) {
        nav.pushAndRemoveUntil(route, (route) => false);
      } else {
        nav.push(route);
      }
    }

    // grovia://invite/<token>
    if (uri.host == 'invite' && uri.pathSegments.isNotEmpty) {
      openPage(InviteAcceptPage(token: uri.pathSegments.first));
      return;
    }

    // grovia://reset-password/<token>
    if (uri.host == 'reset-password' && uri.pathSegments.isNotEmpty) {
      openPage(ResetPasswordPage(token: uri.pathSegments.first));
      return;
    }

    print('[DeepLink] unrecognised URI: $uri');
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

