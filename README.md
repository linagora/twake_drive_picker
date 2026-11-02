# twake_drive_picker

Flutter SDK for the Twake Workplace (Drive) file-picker intent
(`PICK` on `io.cozy.files`) and the oversize-attachment upload. One package
shared by Twake Chat (mobile) and Twake Mail (web and mobile).

It derives from the `workplace` package of
[linagora/tmail-flutter](https://github.com/linagora/tmail-flutter) (see
[NOTICE](NOTICE)). It does not depend on Twake Mail's `core` package.

## Install

The package is consumed from git, pinned to a tag:

```yaml
dependencies:
  twake_drive_picker:
    git:
      url: https://github.com/nqhhdev/twake_drive_picker.git
      ref: v0.2.0
```

Generated files (`*.g.dart`, localizations) are committed, so no
`build_runner` step is needed in the host app.

## Register the localization delegate

The picker strings (10 locales) live in `DrivePickerLocalizations`. Register
its delegate in your `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: [
    ...DrivePickerLocalizations.localizationsDelegates,
    // your own delegates
  ],
  supportedLocales: DrivePickerLocalizations.supportedLocales,
);
```

If the host locale is not one of the shipped ones, or the delegate is missing,
the picker falls back to English (`resolveDrivePickerLocalizations`).

## Platforms

The package picks its platform code with a conditional import, so each app
compiles only what it needs:

| | Mobile (Android / iOS) | Web |
|---|---|---|
| Drive page | `flutter_inappwebview` | `<iframe>` + `postMessage` |
| Cozy bridge | not available | used inside the Twake container app |
| Code | `lib/src/platform/mobile` | `lib/src/platform/web` |

Everything else (domain, data, message parsing, picker logic) is shared and
imports no web library; a test enforces it. `DrivePickerPlatform` is the
interface between the two.

- **Mobile (Twake Chat)**: import `package:twake_drive_picker/twake_drive_picker.dart`
  only. No web code is compiled in.
- **Web (Twake Mail)**: the same import works and, on web builds, also
  re-exports the web classes. You can import
  `package:twake_drive_picker/web.dart` explicitly.

`package:twake_drive_picker/twake_workplace_protocol.dart` (the former name) is
a deprecated re-export, removed in the next release.

## Open the picker

Mix `DrivePickerStateMixin` into the `State` of the widget that opens it, and
give it a way to create an intent. A complete app is in [`example/`](example):

```dart
class _PickButtonState extends State<PickButton> with DrivePickerStateMixin {
  @override
  DrivePickerSession get session => DrivePickerSession(
    uploadFromUrlSupported: () => true,
    maxAttachmentSizeBytesGetter: () => 25 * 1024 * 1024,
    remainingAttachmentCapacityBytesGetter: () => null,
    onFetchIntent: ({required filePickerConfig}) => createIntent(filePickerConfig),
  );

  @override
  DriveIntentImageAssets get driveIntentImageAssets => const DriveIntentImageAssets(
    driveLogo: 'assets/drive.svg',
    closeIcon: 'assets/close.svg',
    searchIcon: 'assets/search.svg',
  );

  @override
  OnPickDriveCallback? get pickerOnCallback => (state) async {
    switch (state) {
      case DrivePickResult(:final documents): /* use documents */
      case DrivePickFailure(:final error): /* show state.message */
      case DrivePickSuccess(): break;
    }
  };

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: onPickerTap, child: const Text('Drive'));
}
```

`createIntent` runs a `CreateDriveIntentCall` through a
`WorkplaceAccessModeRunner` (cozy bridge when available on web, otherwise an
OIDC token exchange); see [`example/lib/src/example_app.dart`](example/lib/src/example_app.dart).

### Mobile

```dart
// main_mobile.dart
import 'package:twake_drive_picker/twake_drive_picker.dart';
```

The Drive page runs in a WebView. The picker only trusts messages whose
sender origin is the native URL of the WebView, cancels navigations away from
the intent origin, and injects its bridge script in the main frame only.

### Web

```dart
// main_web.dart
import 'package:twake_drive_picker/web.dart';

final bridgeAvailable = const WebDrivePickerPlatform().isBridgeAvailable;
```

The Drive page runs in an iframe. Messages are accepted only from that
iframe's window and only from the intent origin.

## Configuration

HTTP settings are injected, not global:

```dart
final config = WorkplaceConfig(
  dio: myDio,          // default: Dio with 10 s timeouts
  requireHttps: true,  // default: true in release builds only
);
final dataSource = WorkplaceDataSourceImpl(config: config);
final executor = WorkplaceRequestExecutor(config: config);
```

## Host app hooks

- Icon buttons: override `DrivePickerStateMixin.driveIconButtonBuilder` with a
  `DriveIconButtonBuilder` to draw the close and search buttons with the app's
  own widget. The default is a plain SVG button.
- Icons: the app supplies the asset paths through `DriveIntentImageAssets`.
- Logging: implement `WorkplaceLogger` and override `workplaceLogger` in the
  mixins (or pass `logger` to the modal). The default drops every line. Logs
  never contain message content, document ids, names or sizes.

## Rules the `done` parser applies

An entry is dropped when it is not a JSON object, its size is negative, or a
`sharingLink` / `downloadLink` is present and is not `http` or `https`. A
missing link is kept. A `done` message whose entries were all dropped is a
failure (`DriveIntentNoValidDocumentException`); one without any entry is a
cancel. A payload that is not a JSON object throws. A message of another
intent is an unknown message.

## Develop

```sh
dart run build_runner build --delete-conflicting-outputs   # after changing a model
flutter gen-l10n                                           # after changing an .arb
dart format --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter test --platform chrome
```

## License and attribution

Licensed under the GNU Affero General Public License v3.0 (see [LICENSE](LICENSE)),
the same license as the upstream project.

This package derives from the `workplace` package of
[linagora/tmail-flutter](https://github.com/linagora/tmail-flutter). It was
extracted into a standalone repository as a fresh history: the upstream git
history and per-commit authorship are not preserved here. Refer to the upstream
repository for the original authors and contributors, and to [NOTICE](NOTICE).
