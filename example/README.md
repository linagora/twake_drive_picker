# twake_drive_picker example

Minimal host app with one entry point per platform.

| Entry | Run |
|---|---|
| Mobile (Android / iOS) | `flutter run -t lib/main_mobile.dart --dart-define=PLATFORM_URL=https://<your cozy> --dart-define=OIDC_TOKEN=ID_TOKEN` |
| Web | `flutter run -d chrome -t lib/main_web.dart --dart-define=PLATFORM_URL=https://<your cozy> --dart-define=OIDC_TOKEN=ID_TOKEN` |

Build the web entry: `flutter build web -t lib/main_web.dart`.

`main_mobile.dart` only imports `package:twake_drive_picker/twake_drive_picker.dart`
(no web code is compiled in). `main_web.dart` also imports
`package:twake_drive_picker/web.dart`. Inside the Twake container app the web
entry reaches Drive through the cozy bridge and needs no token.
