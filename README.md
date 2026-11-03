# twake_drive_picker

Flutter SDK for the Twake Workplace (Drive) file-picker intent (`PICK` on
`io.cozy.files`) and the oversize-attachment upload. One package shared by
Twake Chat (mobile) and Twake Mail (web and mobile). It derives from the
`workplace` package of [linagora/tmail-flutter](https://github.com/linagora/tmail-flutter)
(see [NOTICE](NOTICE)).

## Install

```yaml
dependencies:
  twake_drive_picker:
    git:
      url: https://github.com/nqhhdev/twake_drive_picker.git
      ref: v0.2.0
```

Generated files are committed, so the host app needs no `build_runner` step.
Register `...DrivePickerLocalizations.localizationsDelegates` in your
`MaterialApp` (10 locales; unsupported ones fall back to English).

## Usage

Sign-in is the host app's job in every mode: the picker receives an OIDC id
token (or a configured `Dio`) and the platform URL, never runs SSO itself.
Import `package:twake_drive_picker/twake_drive_picker.dart`; `core.dart` is the
UI-free part.

**1. Full UI** (as Tmail): mix `DrivePickerStateMixin` into a `State`, call
`onPickerTap`, get a `DrivePickState` in `pickerOnCallback`.

**2. Embeddable widget** (as Chat): put `DriveIntentWebView` in your own sheet
or route.

```dart
DriveIntentWebView(
  intentLoader: () => createIntent(filePickerConfig), // your SSO + intent
  filePickerConfig: filePickerConfig,
  onResult: (outcome) { /* Picked / Cancelled / Failed */ },
  onClose: () => Navigator.of(sheetContext).pop(),
)
```

**3. Headless**: with `core.dart`, exchange the token, create the intent, open
`intent.intentUrl` in your own WebView and map each page message:

```dart
final outcome = drivePickOutcomeOfMessage(
  WorkplaceIntentMessage.parse(intent.intentId, raw),
); // null while the handshake goes on
```

A complete app is in [`example/`](example); the headless flow is in
[`example/lib/headless_example.dart`](example/lib/headless_example.dart).

## Documentation

- [ADR 1: core / UI split and abstractions](docs/adr/0001-core-ui-split-and-abstractions.md)
- [ADR 2: integrating the picker in an app](docs/adr/0002-integrating-the-picker-in-an-app.md)
  (modes, picker options, required Drive version, errors)
- [CHANGELOG](CHANGELOG.md)

## Develop

```sh
dart run build_runner build --delete-conflicting-outputs   # after changing a model
flutter gen-l10n                                           # after changing an .arb
dart format --set-exit-if-changed lib test example/lib
flutter analyze
flutter test
flutter test --platform chrome
```

## License

GNU Affero General Public License v3.0 (see [LICENSE](LICENSE)), the same as
the upstream project. Extracted as a fresh history: upstream authorship is not
preserved here; see the upstream repository and [NOTICE](NOTICE).
