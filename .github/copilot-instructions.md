# Grovia – Copilot Instructions

## Project Overview
**Grovia** is a Flutter grocery-list app (package: `grocery_app_landing`). It connects to a Node.js/Express + MongoDB backend hosted on DigitalOcean App Platform. The Flutter front-end targets iOS, Android, macOS, web, and Linux.

## Architecture & Data Flow
```
SplashScreen → LandingPage (root shell)
  ├── LandingHeader       (avatar, theme toggle, locale toggle via ValueNotifiers)
  ├── MarketingCard       (fetches /api/marketing via MarketingApiService)
  ├── ListSectionWithApi  (fetches /api/lists via ApiService; GlobalKey exposes refresh())
  └── FooterMenu          (Home / Profile / Settings — navigates with pushAndRemoveUntil)
```
- State is managed with plain `StatefulWidget`; **no** Provider / Riverpod / Bloc.
- Three global `ValueNotifier`s in `lib/main.dart` drive cross-widget state: `themeModeNotifier`, `localeNotifier`, `userNameNotifier`.
- Auth JWT + display name are persisted via `flutter_secure_storage` inside `ApiService`.
- Call `_listKey.currentState!.refresh()` (GlobalKey) to reload the list section without rebuilding parents.

## Key Files
| File | Role |
|------|------|
| `lib/main.dart` | Entry point; global notifiers; loads `.env` with `flutter_dotenv` |
| `lib/theme.dart` | `AppTheme.light()` / `AppTheme.dark()` — brand palette |
| `lib/services/api_service.dart` | All REST calls; `baseUrl` from `--dart-define=API_BASE_URL` |
| `lib/services/openai_service.dart` | GPT-3.5-turbo for parsing voice commands → `{product, qty}` |
| `lib/l10n/` | ARB files (`app_en.arb`, `app_ar.arb`); run `flutter gen-l10n` after edits |
| `backend/server.js` | Express app; requires `PORT` and `MONGODB_URI` env vars at startup |

## Fonts & Assets
- **Nunito** is the primary typeface, bundled as a variable TTF in `assets/fonts/` and declared in `pubspec.yaml`. Use `fontFamily: 'Nunito'` directly — **do not** use `google_fonts` for Nunito.
- `google_fonts` is still available for any secondary/decorative faces only.
- All images live in `assets/images/`; every new image file must be listed under `assets:` in `pubspec.yaml`.

## Localization Workflow
Strings live in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`. After editing an ARB file:
```bash
flutter gen-l10n
```
Access strings as `AppLocalizations.of(context)!.myKey`. Never hardcode user-visible strings.

## Running the App
```bash
flutter pub get
flutter run -d <device>                                                         # uses prod backend
flutter run -d <device> --dart-define=API_BASE_URL=http://my-mac.local:3000/api # local backend
./scripts/print_host.sh   # prints the mDNS name for physical-device LAN testing
```
VS Code tasks for Android emulator, iOS simulator, physical iPhone, and macOS are pre-configured.

## Backend (local dev)
```bash
cd backend && npm install
PORT=3000 MONGODB_URI=<uri> node server.js
```

## API Conventions
- All calls go through `ApiService` (instantiate as `final _api = ApiService()`).
- Production base URL defaults to `https://coral-app-qjq4a.ondigitalocean.app/api`; override per-device with `--dart-define=API_BASE_URL=...`.
- Backend items may return `_id` (MongoDB); `ApiService.fetchListItems` normalises it to `id`.
- Icon names in list JSON map to `IconData` in `GroceryList._getIconFromString`. Valid values: `shopping_cart`, `celebration`, `breakfast`, `cleaning`, `apple`, `inventory`, `child_care`, `pets`.

## Brand Palette (`lib/theme.dart`)
| Token | Hex | Usage |
|-------|-----|-------|
| `colorScheme.primary` | `#E53935` | Red — buttons, FAB, AppBar |
| `colorScheme.secondary` | `#1A237E` | Dark blue — hero background |
| `colorScheme.tertiary` | `#42A5F5` | Accent blue |
| `AppTheme.successColor` | `#43A047` | Success states (not in ColorScheme) |

## UI Patterns
- Always derive colors from `Theme.of(context).colorScheme`; avoid hardcoded hex in widgets.
- Bottom sheets: `showModalBottomSheet` with `isScrollControlled: true, backgroundColor: Colors.transparent` (see `lib/widgets/add_item_details_sheet.dart`).
- Use `AppDialog` (`lib/widgets/app_dialog.dart`) for confirmations and alerts.
- Scaffold placeholder assets in `assets/images/` and list them in `pubspec.yaml`.
