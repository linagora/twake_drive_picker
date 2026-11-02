import 'package:twake_drive_picker/src/picker/drive_origin_validator.dart';

/// Reads the real, native URL of the WebView's main frame.
typedef CurrentUrlGetter = Future<Uri?> Function();

/// Forwards a message from the JS handler to the picker with an origin the
/// page cannot choose.
///
/// A JS handler carries no sender identity, and the page controls every
/// argument it passes. So the origin handed on is derived from the WebView's
/// current main-frame URL, which only a navigation (restricted to the intent
/// origin by [isNavigationToIntentOriginAllowed]) can change.
class MobileMessageGate {
  const MobileMessageGate({required this.currentUrl, required this.onMessage});

  final CurrentUrlGetter currentUrl;
  final void Function({required String raw, required String? origin}) onMessage;

  Future<void> handle(List<dynamic> args) async {
    if (args.isEmpty) return;
    final raw = args.first;
    if (raw is! String) return;
    // Any further argument is page-controlled and deliberately ignored.
    final url = await currentUrl();
    onMessage(raw: raw, origin: url == null ? null : tryGetUriOrigin(url));
  }
}

/// Whether the WebView may navigate to [url] while showing the Drive intent
/// page served from [intentOrigin]. Anything else (other hosts, `data:`,
/// `file:`, custom schemes, `javascript:`) is cancelled.
bool isNavigationToIntentOriginAllowed(
  Uri? url, {
  required String intentOrigin,
}) {
  if (url == null || intentOrigin.isEmpty) return false;
  if (url.toString() == 'about:blank') return true;
  return tryGetUriOrigin(url) == intentOrigin;
}
