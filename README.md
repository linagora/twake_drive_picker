# twake_drive_picker

Flutter SDK for the Twake Workplace (Drive) file-picker intent
(`PICK` on `io.cozy.files`) and the oversize-attachment upload, moved from the
`workplace` package of Twake Mail so Twake Mail and Twake Chat share one
implementation.

Synced with [linagora/tmail-flutter](https://github.com/linagora/tmail-flutter)
`workplace` at `e1210bf` (v0.41.0). The package stays standalone: it does not
depend on Twake Mail's `core` package. Logging goes through `WorkplaceLogger`
(`activeWorkplaceLogger`). Picker icon buttons go through
`DriveIconButtonBuilder`.

## What it contains

- `entity/`, `model/`, `message/`, `picker/`: protocol models, DTOs
  (`json_serializable`), the `postMessage` parser and the origin check.
- `data/`: Cozy bridge (web and stub), Dio client, request executor, intent
  datasource, Drive upload and share-link datasource, repository, access-mode
  runner.
- `domain/`: repository interface, intent and upload interactors, states,
  exceptions.
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

Same rules as Twake Mail. An entry is dropped when it is not a JSON object,
its size is negative, or a `sharingLink` / `downloadLink` is present and is
not `http` or `https`. A missing link is kept. An unsafe thumbnail does not
drop the document. A payload that is not a JSON object throws. A message of
another intent is an unknown message.

## Use

```yaml
dependencies:
  twake_drive_picker:
    git:
      url: https://github.com/nqhhdev/twake_drive_picker.git
      ref: v0.2.0
```

```dart
import 'package:twake_drive_picker/twake_drive_picker.dart';

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
