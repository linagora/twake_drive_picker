# Changelog

## 0.2.0

First release under the name `twake_drive_picker` (it was
`twake_workplace_protocol`). Not tagged yet.

### Breaking changes

- Package renamed to `twake_drive_picker`. Import
  `package:twake_drive_picker/twake_drive_picker.dart`;
  `package:twake_drive_picker/twake_workplace_protocol.dart` still works but is
  deprecated and will be removed in the next release.
- `AppLocalizations` is now `DrivePickerLocalizations` (the old name only
  exists as a deprecated alias in the deprecated entry point).
- The global `WorkplaceDio` is removed. Pass a `WorkplaceConfig(dio:,
  requireHttps:)` to `WorkplaceDataSourceImpl` / `WorkplaceRequestExecutor`.
  Defaults are unchanged (10 s timeouts, https required in release builds).
- `WorkplaceDataSourceImpl.parseIntentResponse(requireHttps:)` is now
  nullable and defaults to the config value.
- `WebWindowMessageMixin` and the web classes are no longer exported from the
  main library on non-web builds; use `package:twake_drive_picker/web.dart`.
- `MobileDriveOriginValidator` no longer accepts the intent `client` as an
  origin, and no validator accepts `*` or the opaque `null` origin. `data:`
  intents (and the built-in fake Drive page) are removed.
- `DriveIntentWebViewModal` is now a thin widget delegating to the
  `DrivePickerPlatform`; it takes an optional `platform`.

### Added

- `DrivePickerPlatform` with `MobileDrivePickerPlatform`
  (`flutter_inappwebview`) and `WebDrivePickerPlatform` (iframe, `postMessage`,
  cozy bridge), selected by a conditional import.
- `WorkplaceConfig`, `resolveDrivePickerLocalizations`,
  `WorkplaceIntentDoneMessage.skippedCount`,
  `DriveIntentNoValidDocumentException`, `tryGetUriOrigin`.
- Example app (`example/`) with a mobile and a web entry point.

### Fixed

- Mobile: the sender origin is read from the WebView's native URL instead of
  the page-supplied `targetOrigin`; the shim only runs in the main frame and
  navigations away from the intent origin are cancelled.
- Web: messages are only accepted from the picker iframe's window.
- Logs no longer contain message content, document ids, names or sizes.
- A `done` message whose documents were all rejected is a failure (an empty one
  a cancel) instead of an empty pick.
- An intent URL without an http(s) origin fails fast instead of throwing.
- An unsupported host locale falls back to English instead of failing.
- All analyzer infos fixed; unused code removed.
