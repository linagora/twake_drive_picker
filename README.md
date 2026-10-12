# twake-workplace-protocol

Pure Dart models, message parser and origin check for the Twake Workplace
file-picker intent (`PICK` on `io.cozy.files`), shared by Twake Mail and Twake
Chat. No Flutter dependency.

## What it contains

- `entity/`: `DriveDocument`, `WorkplaceIntent`, `WorkplaceIntentConfig`,
  `WorkplaceActionConfig`, `WorkplaceTheme`, `WorkplaceIntentAccessMode`.
- `model/`: request and response DTOs for `POST /intents` and
  `POST /auth/token_exchange`, with the wire enums (`json_serializable`).
- `message/`: `parseWorkplaceIntentMessage` for the `postMessage` kinds
  `ready`, `readyToUse`, `done`, `error` and `cancel`.
- `picker/`: `DriveOriginValidator`, `DrivePickOutcome`.

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

final message = WorkplaceIntentMessage.parse(intentId, raw);
```

## Develop

Generated files (`*.g.dart`) are committed because a git dependency cannot run
`build_runner`. After changing a model:

```sh
dart run build_runner build --delete-conflicting-outputs
dart analyze
dart test
```
