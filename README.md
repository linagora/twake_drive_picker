# twake-workplace-protocol

Flutter SDK for the Twake Workplace (Drive) file-picker intent
(`PICK` on `io.cozy.files`), moved from the `workplace` package of Twake Mail so
Twake Mail and Twake Chat share one implementation.

## What it contains

- `entity/`, `model/`, `message/`, `picker/`: protocol models, DTOs
  (`json_serializable`), the `postMessage` parser and the origin check.
- `data/`: Cozy bridge (web and stub), Dio client, datasource, repository.
- `domain/`: repository interface, interactors, states, exceptions.
- `presentation/`: picker mixins, `DrivePickerSession`, the picker modal
  (web iframe, mobile webview), skeleton loader.
- `l10n/`: picker strings (10 locales).

## Host app hooks

- Icon buttons: pass a `DriveIconButtonBuilder` (override
  `DrivePickerStateMixin.driveIconButtonBuilder`) to draw the close and search
  buttons with the app's own widget. The default is a plain SVG button.
- Icons: the app supplies the asset paths through `DriveIntentImageAssets`.
- Logging: implement `WorkplaceLogger` and override `workplaceLogger` in the mixins (or pass `logger` to the modal); the default `NoopWorkplaceLogger` drops every line.
- Not included (stay in Twake Mail): composer plugin, picker button, context
  menu tile and the editor scripts.

## Rules the `done` parser applies

An entry is dropped when its id or name is blank, its size is negative or
missing, it has no `sharingLink` and no `downloadLink`, or a link is not safe.
Links must be `https`; pass `allowInsecureLinks: true` to also accept `http`.
An unsafe thumbnail removes only the thumbnail. `onSkipped` receives the reason
(never a link). A payload that is not a JSON object throws `FormatException`;
a message of another intent, or a non-string `type`, is an unknown message.

## Use

```yaml
dependencies:
  twake_workplace_protocol:
    git:
      url: https://github.com/nqhhdev/twake-workplace-protocol.git
      ref: v0.1.0
```

```dart
import 'package:twake_workplace_protocol/twake_workplace_protocol.dart';

final message = parseWorkplaceIntentMessage(intentId, raw);
```

## Develop

Generated files (`*.g.dart`) are committed because a git dependency cannot run
`build_runner`. After changing a model:

```sh
dart run build_runner build --delete-conflicting-outputs
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
repository for the original authors and contributors.
