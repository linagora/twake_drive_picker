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

## Entry points

| Import | Contains | Use it for |
|---|---|---|
| `package:twake_drive_picker/core.dart` | datasource, repository, interactors, `CozyBridge`, intent request / state, `DrivePickOutcome`, origin validator, message parsing | headless use; imports no widget, WebView or browser library (a test enforces it) |
| `package:twake_drive_picker/ui.dart` | the dialog modal, `DriveIntentWebView`, shell, mixins, localizations, platforms | the picker UI |
| `package:twake_drive_picker/twake_drive_picker.dart` | both of the above | existing apps such as Tmail; same surface as before |
| `package:twake_drive_picker/web.dart` | the web platform classes | web apps that need them explicitly |

- **Mobile (Twake Chat)**: import `package:twake_drive_picker/twake_drive_picker.dart`
  only. No web code is compiled in.
- **Web (Twake Mail)**: the same import works and, on web builds, also
  re-exports the web classes. You can import
  `package:twake_drive_picker/web.dart` explicitly.

`package:twake_drive_picker/twake_workplace_protocol.dart` (the former name) is
a deprecated re-export, removed in the next release.

## Usage modes

| Mode | For | Entry point |
|---|---|---|
| 1. Full UI | Tmail: tap, dialog, result callback | `DrivePickerStateMixin` + `DriveIntentWebViewModal` |
| 2. Embeddable widget | Chat: the picker in your own sheet or route | `DriveIntentWebView` |
| 3. Headless core | your own WebView or flow, no widget | `core.dart` |

**Sign-in is the host app's job in every mode.** The picker contains no SSO
logic: it receives an OIDC id token (to trade for a Drive access token) or a
configured `Dio`, plus the platform URL (`workplaceFqdn`).

### 1. Full UI (as Tmail)

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

#### Mobile

```dart
// main_mobile.dart
import 'package:twake_drive_picker/twake_drive_picker.dart';
```

The Drive page runs in a WebView. The picker only trusts messages whose
sender origin is the native URL of the WebView, cancels navigations away from
the intent origin, and injects its bridge script in the main frame only.

#### Web

```dart
// main_web.dart
import 'package:twake_drive_picker/web.dart';

final bridgeAvailable = const WebDrivePickerPlatform().isBridgeAvailable;
```

The Drive page runs in an iframe. Messages are accepted only from that
iframe's window and only from the intent origin.

### 2. Embeddable widget (as Chat)

`DriveIntentWebView` is the picker without a dialog: it fills the space its
parent gives it and reports through callbacks, so you wrap it in your own
bottom sheet or route. `DriveIntentWebViewModal` is this view inside the
dialog.

```dart
showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) => SizedBox(
    height: MediaQuery.sizeOf(context).height * 0.9,
    child: DriveIntentWebView(
      intentLoader: () => createIntent(filePickerConfig), // your SSO + intent
      filePickerConfig: filePickerConfig,
      onResult: (outcome) {
        switch (outcome) {
          case DrivePickOutcomePicked(:final documents): /* use documents */
          case DrivePickOutcomeFailed(:final error): /* report */
          case DrivePickOutcomeCancelled(): break;
        }
      },
      onClose: () => Navigator.of(sheetContext).pop(),
    ),
  ),
);
```

- `onResult` is called once with the outcome; `onClose` right after, for every
  outcome, so the sheet is always dismissed. The view never pops a route.
- `imageAssets`, `iconButtonBuilder` and `logger` are optional. Without
  `imageAssets` the loading overlay is a spinner and the close button a
  Material icon; give them to get the Drive skeleton and your own buttons.
- The theme (light / dark) is part of `filePickerConfig`.
- `platform` can be passed to replace the compiled-in one (tests).

### 3. Headless core

Use `core.dart` when you run the Drive page yourself. Exchange the token,
create the intent, open `intent.intentUrl` in your own WebView, and turn what
the page posts into a `DrivePickOutcome`:

```dart
import 'package:twake_drive_picker/core.dart';

final config = WorkplaceConfig(dio: appDio); // your Dio; optional
final executor = WorkplaceRequestExecutor(config: config);
final repository = WorkplaceRepositoryImpl(
  WorkplaceDataSourceImpl(executor: executor, config: config),
  WorkplaceDriveDataSourceImpl(executor: executor),
);
final runner = WorkplaceAccessModeRunner(
  exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
  oidcTokenGetter: () => session.oidcIdToken,      // your SSO
  oidcRefreshTrigger: () => session.refreshIdToken, // your SSO
);

final platformUrl = Uri.https(workplaceFqdn);
final intent = await runner.run(
  platformUrl,
  CreateDriveIntentCall(
    CreateDriveIntentInteractor(repository),
    platformUrl,
    const WorkplaceIntentConfig(
      addAsLink: WorkplaceActionConfig(label: 'Add as link'),
      theme: WorkplaceTheme.light,
    ),
  ),
);

// For each message the page posts (origin: from the WebView, not the page):
final outcome = drivePickOutcomeOfMessage(
  WorkplaceIntentMessage.parse(intent.intentId, raw),
); // null while the handshake goes on
```

Check the sender origin against `tryGetUriOrigin(intent.intentUrl)` with a
`DriveOriginValidator` before trusting a message. A complete, compiled version
is in [`example/lib/headless_example.dart`](example/lib/headless_example.dart)
and is exercised by `test/headless_flow_test.dart`.

### Optional picker options

Drive reads these from the picker config. Every one is optional; when unset it
is left out of the request and Drive keeps its default, so nothing changes for
existing callers.

| Where | Option | Drive default |
|---|---|---|
| `WorkplaceIntentConfig` / `WorkplaceFilePickerConfigRequest` | `multiple` | `true` |
| | `defaultDirId` | root |
| | `restrictToDefaultDir` | `false` |
| | `tabs` (`drive`, `recents`, `sharings`) | all three |
| `WorkplaceActionConfig` / `WorkplaceActionConfigRequest` | `allowFolder` | links yes, attachments no |
| | `accept` (`file`, `folder`, mime patterns such as `image/*`) | any |
| | `maxFileCount` | no limit |

These keys are read by the Drive app (`linagora/twake-drive`,
`FilePicker/config.js` and `constraints.js`); they are not in the public
cozy-stack intents documentation, so check the Drive version you deploy against.

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
