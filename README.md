# GroceryAppLanding

This workspace is a Flutter scaffold to implement the landing page design from Figma:

Figma design: https://www.figma.com/design/M1SuEkVxulTYMkmjKgtjmh/Untitled?node-id=0-1&p=f&t=mDEbGk2DbR9jE5Se-0

What's included
- Minimal `pubspec.yaml` with `google_fonts` dependency and `assets/images/` included.
- Placeholder SVG assets in `assets/images/`.
- Minimal `lib/main.dart` starter so you can run the app.

How to run (macOS)
1. Install Flutter (if not already) and ensure `flutter` is on your PATH.
2. In this project root run:

```bash
flutter pub get
flutter run
```

Notes
- Fonts are handled with the `google_fonts` package to avoid bundling font files in this first pass.
- Replace placeholder images in `assets/images/` with production assets and update `pubspec.yaml` if you add new folders.

## Local backend hostname and devices

During development you may run the backend on your machine and test the app on simulators, emulators, or physical devices. To avoid hard-coded LAN IPs, the app now chooses the API host with this priority:

- Use explicit override: `--dart-define=API_HOST=my-mac.local:3000` (highest priority)
- Android emulator: `10.0.2.2:3000` (maps to host localhost)
- iOS / macOS: tries `$(Platform.localHostname).local:3000` (mDNS) when available
- Web / fallback: `localhost:3000`

If you need a stable name to reach your dev machine from a phone on the same Wi‑Fi, run the helper script to print a recommended mDNS name:

```bash
./scripts/print_host.sh
```

Or run the app with an explicit host override:

```bash
flutter run -d <device> --dart-define=API_HOST=my-mac.local:3000
```

This avoids changing source code every time your LAN IP changes.
