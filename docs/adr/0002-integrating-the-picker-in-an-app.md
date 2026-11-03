# 2. Integrating the picker in an app

## Status

Accepted

## Context

Twake Mail (web and mobile) and Twake Chat (mobile) both let users pick files
from Twake Drive (the `PICK` intent on `io.cozy.files`). They differ in how much
of the flow they own: Mail wants the ready-made dialog, Chat has its own sheet
and its own sign-in, and a third kind of host may want to run the Drive page
itself. See [ADR 1](0001-core-ui-split-and-abstractions.md) for the layering
this relies on.

## Decision

### Three usage modes

| Mode | For | Entry point |
|---|---|---|
| 1. Full UI | Tmail: tap, dialog, result callback | `DrivePickerStateMixin` + `DriveIntentWebViewModal` |
| 2. Embeddable widget | Chat: the picker in the host's own sheet or route | `DriveIntentWebView` |
| 3. Headless | the host runs the Drive page | `core.dart` + `drivePickOutcomeOfMessage` |

1. **Modal.** `DriveIntentWebViewModal` loads the intent page and pops a
   `DrivePickOutcome`. `DrivePickerStateMixin.onPickerTap` opens it with
   `showDialog` and turns the outcome into a `DrivePickState`
   (`DrivePickResult`, `DrivePickFailure`) for `pickerOnCallback`; a cancel
   produces no callback.
2. **Embeddable view.** `DriveIntentWebView` fills its parent and never pops a
   route. It calls `onResult` once with the `DrivePickOutcome`, then `onClose`
   for every outcome (also when `onResult` throws), so the host can always
   dismiss its container. `imageAssets` is optional: without it the loading
   overlay is a spinner and the close button a Material icon. The close button
   of the loading overlay reports a cancel.
3. **Headless.** The host exchanges the token, creates the intent
   (`WorkplaceAccessModeRunner` + `CreateDriveIntentCall`), opens
   `intent.intentUrl` in its own WebView, and maps each message the page posts
   with `drivePickOutcomeOfMessage(WorkplaceIntentMessage.parse(intent.intentId,
   raw))`, which returns null while the handshake goes on. The host must check
   the sender origin against `tryGetUriOrigin(intent.intentUrl)` with a
   `DriveOriginValidator` before trusting a message. A compiled example is
   `example/lib/headless_example.dart`, exercised by
   `test/headless_flow_test.dart`.

### The host owns sign-in

The picker contains no SSO. It receives an OIDC id token through
`oidcTokenGetter` / `oidcRefreshTrigger` of `WorkplaceAccessModeRunner` (or a
configured `Dio` through `WorkplaceConfig`), plus the platform URL
(`workplaceFqdn`). The runner posts the id token to `<platformUrl>/auth/token_exchange`
for a Drive access token. When that fails with 400 or 401 it retries once: with
a newer token if the host already holds one, otherwise after
`oidcRefreshTrigger`. Without an OIDC token the call fails with a `StateError`.

On web, inside the Twake container app, the cozy bridge is used when available
and no token is needed; creating the intent falls back to the bearer token if
the bridge call fails. Mobile has no bridge.

The host-side reference for the sign-in flow is the React app
`linagora/twake-space-chat` (OpenID login, `workplaceFqdn`, then
`token_exchange`). It was named by the team and was not re-read when writing
this ADR.

### Drive version

The picker options below are read by the Drive app, not by cozy-stack, and are
not in the public cozy-stack intents documentation. They are supported from
Twake Drive [1.108.0](https://github.com/linagora/twake-drive/tree/1.108.0)
(`FilePicker/config.js`, `FilePicker/constraints.js`, `intentConfig.js`,
`pickerNavigation.js`). An older Drive ignores them.

### Picker options

All optional. A null option is omitted from the request JSON and Drive keeps
its default, so existing callers send exactly what they sent before.

| Where | Option | Drive default | Meaning and Drive behavior |
|---|---|---|---|
| `WorkplaceIntentConfig` | `multiple` | `true` | Several items can be selected. |
| | `defaultDirId` | root | Folder opened on the Drive tab. An id Drive cannot resolve on its instance falls back to the root, unless `restrictToDefaultDir` is true. |
| | `restrictToDefaultDir` | `false` | Navigation and selection stay in `defaultDirId`; only the Drive tab is shown. |
| | `tabs` (`drive`, `recents`, `sharings`) | all three | Tabs to show, in Drive's own order, not the list's. |
| `WorkplaceActionConfig` | `allowFolder` | links yes, attachments no | Legacy in Drive: ignored when `accept` is set; attachments never take folders. |
| | `accept` (`file`, `folder`, mime patterns such as `image/*`) | from `allowFolder` | Any entry matches (OR). An empty list accepts nothing. |
| | `maxFileCount` | no limit | Counts every selected item, folders included. |

`WorkplaceActionConfig` applies per action (`addAsLink`, `addAsAttachment`);
`WorkplaceIntentConfig.addAsAttachment` null hides the attachment button.

**Invalid combinations.** Drive fails the intent on: empty `tabs`;
`restrictToDefaultDir: true` without `defaultDirId`; `restrictToDefaultDir:
true` with `tabs` other than `[drive]`. The package does not validate these.
Leave an option unset unless it is needed.

**Where to set them.** The same values travel on two paths: the intent
creation request (`WorkplaceIntentConfig`, built by `WorkplaceDataSourceImpl`)
and the handshake ack, where the picker hands its
`WorkplaceFilePickerConfigRequest` to the Drive page (web: `postMessage` to the
exact intent origin, never `*`; mobile: a message event dispatched in the page
with the intent client as origin). A host that embeds the view builds that request
itself. `DrivePickerStateMixin` builds it with the labels, attachment sizes and
theme only, so mode 1 sends no option. Which of the two paths Drive reads for
which option was not verified against the Drive source for this ADR; set the
same value on both.

### Outcomes and errors

`DrivePickOutcome` is `Picked(documents)`, `Cancelled` or `Failed(error)`. A
`done` message with documents is picked; with nothing selected, cancelled; with
every entry rejected (not a JSON object, negative size, or a non-http(s)
`sharingLink` / `downloadLink`), failed with `DriveIntentNoValidDocumentException`.
The page's `error` message fails with `DriveIntentErrorException`, a `cancel`
message cancels. Other failures come back as `Failed` too:

- the intent loader throws (including `WorkplaceExchangeTokenException`,
  `WorkplaceCreateIntentException`, the `StateError`s above);
- `DriveIntentPageLoadException`: the intent URL is not http(s), or the page
  failed to load;
- `DriveIntentTimeoutException`: no `ready` within 20 seconds.

The failure is logged once at the failing stage, through `WorkplaceLogger`
(the default drops every line; logs carry no message content, document ids,
names or sizes).

### Trust boundaries

Mobile only trusts messages whose sender origin is the WebView's native URL,
cancels navigations away from the intent origin, and injects its script in the
main frame only. Web accepts messages only from the picker iframe's window and
the intent origin.

## Consequences

- Each host takes the amount of the flow it wants, and sign-in stays in one
  place: the host app. A bad or expired OIDC token is the host's to refresh.
- The picker options depend on the deployed Drive version. The package cannot
  detect it, so the host must check the version it deploys against.
- The package does not validate option combinations; an invalid one surfaces
  as a failed intent.
- Mode 1 cannot send options without a change to
  `DrivePickerStateMixin`'s config; modes 2 and 3 can.
- **Not verified:** a live run on a device against a real Drive. What the
  repository tests (unit, widget, `flutter test --platform chrome`) cover is
  the request JSON, the message parsing and the callbacks, not the Drive
  page's behavior or the Drive version claims above.
