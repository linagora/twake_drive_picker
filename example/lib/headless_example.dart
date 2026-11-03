// Headless use of the picker: no widget, no WebView, only `core.dart`.
//
// Single sign-on is NOT done by the picker. The host app signs the user in
// (OIDC) and owns the session; the picker only receives the current OIDC id
// token, through the getter below, to trade it for a Drive access token, plus
// the platform URL (`workplaceFqdn`).
import 'package:twake_drive_picker/core.dart';

class HeadlessDrivePicker {
  /// [oidcIdToken] returns the app's current OIDC id token (null when signed
  /// out); [refreshOidcIdToken] is called once when Drive rejects a stale one.
  /// [config] is optional: build it with the app's own `Dio` to share its
  /// interceptors, proxy and certificates.
  HeadlessDrivePicker({
    required String workplaceFqdn,
    required String? Function() oidcIdToken,
    required Future<String?> Function() refreshOidcIdToken,
    WorkplaceConfig? config,
  }) : platformUrl = Uri.https(workplaceFqdn) {
    final resolved = config ?? WorkplaceConfig();
    final executor = WorkplaceRequestExecutor(config: resolved);
    final repository = WorkplaceRepositoryImpl(
      WorkplaceDataSourceImpl(executor: executor, config: resolved),
      WorkplaceDriveDataSourceImpl(executor: executor),
    );
    _createIntent = CreateDriveIntentInteractor(repository);
    _runner = WorkplaceAccessModeRunner(
      exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
      oidcTokenGetter: oidcIdToken,
      oidcRefreshTrigger: refreshOidcIdToken,
    );
  }

  final Uri platformUrl;
  late final CreateDriveIntentInteractor _createIntent;
  late final WorkplaceAccessModeRunner _runner;

  /// Exchanges the OIDC token for a Drive access token, then creates the PICK
  /// intent. Open [WorkplaceIntent.intentUrl] in a WebView of your own and
  /// pass every message the page posts to [outcomeOf].
  Future<WorkplaceIntent> createIntent(WorkplaceIntentConfig config) =>
      _runner.run(
        platformUrl,
        CreateDriveIntentCall(_createIntent, platformUrl, config),
      );

  /// Decodes one message of the Drive page. Returns the outcome once the page
  /// is done, cancelled or failed, and null for the rest of the handshake or
  /// when the message does not come from the intent page.
  ///
  /// [origin] is the origin of the sender as the platform reports it (on
  /// mobile, the WebView's native URL); never a value the page supplies.
  DrivePickOutcome? outcomeOf(
    WorkplaceIntent intent, {
    required String raw,
    required String? origin,
  }) {
    final intentOrigin = tryGetUriOrigin(intent.intentUrl);
    if (intentOrigin == null) return null;
    final trusted = const MobileDriveOriginValidator().isValid(
      origin,
      intentOrigin: intentOrigin,
      intentClient: intent.client,
    );
    if (!trusted) return null;
    return drivePickOutcomeOfMessage(
      WorkplaceIntentMessage.parse(intent.intentId, raw),
    );
  }
}
