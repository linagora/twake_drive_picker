# 1. Split a UI-free core from the UI, behind small abstractions

## Status

Accepted

## Context

The package comes from the `workplace` package of Twake Mail
(`linagora/tmail-flutter`, see [NOTICE](../../NOTICE)). There it was one block:
the data layer reached the cozy bridge through web code, and the picker dialog
was the only way to use it.

Two hosts now share it:

- Twake Mail (web and mobile) already ships the Tmail-derived code, so its
  public API and behavior must not break.
- Twake Chat (mobile) owns its sign-in and its own sheets and routes. It needs
  to embed the picker, or to run the Drive page itself, without pulling in the
  Tmail dialog or any web code.

## Decision

**Two libraries, one barrel.**

- `lib/core.dart` is UI-free: datasource, repository, interactors, intent
  request / state, `DrivePickOutcome`, `drivePickOutcomeOfMessage`, origin
  validator, message parsing. It reaches no widget, no WebView and no
  `src/presentation`, `src/l10n` or `src/platform` file. The one exception is
  the cozy bridge, whose browser implementation is selected by a conditional
  import (`dart.library.html`).
- `lib/ui.dart` holds the widgets, mixins, localizations and the mobile / web
  platforms.
- `lib/twake_drive_picker.dart` exports both and keeps the surface existing
  apps import. `lib/web.dart` exports the web classes explicitly.
  `lib/twake_workplace_protocol.dart` (the former name) is a deprecated
  re-export, removed in the next release.

`test/platform/core_isolation_test.dart` walks the imports of `core.dart` and
fails if one reaches the forbidden files, and checks that no web library is
imported outside `platform/web` and the conditional selectors.
`test/core_entry_point_test.dart` imports only `core.dart`.

**Depend on abstractions.**

- `CozyBridgeTransport` (in core) is what the data layer uses to reach
  cozy-stack through the cozy bridge. `UnsupportedCozyBridgeTransport` is the
  no-bridge implementation: `isBridgeSupported` is false and `fetchJson` throws
  `UnsupportedError`.
- `DrivePickerPlatform` (in ui) extends `CozyBridgeTransport` with what the UI
  needs: `buildModal`, `buildView`, `listenToWindowMessages`.
  `MobileDrivePickerPlatform` (`flutter_inappwebview`) and
  `WebDrivePickerPlatform` (iframe, `postMessage`) implement it; a conditional
  import picks one, so a mobile build never compiles the web code. Widgets take
  an optional `platform:` to replace it (tests, custom hosts).
- `WorkplaceRequestExecutor` and `WorkplaceAccessModeRunner` take the transport
  as `bridge:`.

**Compatibility rule: no behavior or API break for Tmail's stable code.**

- New members are additive. `DrivePickerPlatform.buildView` is not abstract; its
  default throws an `UnsupportedError`, so a platform that only implements
  `buildModal` keeps compiling and keeps working with the modal
  (`test/platform/legacy_platform_compat_test.dart`).
- `platform:` on `WorkplaceRequestExecutor` and `WorkplaceAccessModeRunner` is
  kept as a deprecated alias of `bridge:` (`bridge:` wins when both are given),
  removed in the next release.
- New picker options are nullable and omitted from the request JSON when unset,
  so the request sent by existing callers is unchanged.
- `test/public_api_smoke_test.dart` locks the export surface of the barrel;
  `test/deprecated_entry_point_test.dart` covers the old entry point.

The Tmail-derived dialog flow (`DrivePickerStateMixin` +
`DriveIntentWebViewModal`) is left as it was; the embeddable widget is built
beside it, and the modal is that widget inside a dialog.

## Consequences

- A host can use `core.dart` alone, or the embeddable widget, without the
  Tmail dialog.
- The same package serves mobile and web; mobile builds carry no web code.
- Changing a type exported by the barrel is a visible change (the smoke test
  fails), which is intended.
- Two names exist for the transport parameter (`bridge:`, deprecated
  `platform:`) until the next release.
- A custom `DrivePickerPlatform` fails at run time, not at compile time, if it
  does not override `buildView` and a host uses `DriveIntentWebView` with it.
- "UI-free" means no widget or WebView, not "no conditional import": `core.dart`
  still reaches the browser bridge on web builds.
