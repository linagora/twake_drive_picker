bool isValidDriveClient(String? client) =>
    client != null && client.trim().isNotEmpty && client != '*';

/// `scheme://host[:port]` of an http(s) [url], or null when it has none.
///
/// [Uri.origin] throws for host-less or non-http(s) URLs (`data:`, `file:`,
/// relative references); an intent URL like that can never be a Drive page.
String? tryGetUriOrigin(Uri url) {
  try {
    return url.origin;
  } on StateError {
    return null;
  }
}

/// Validates a postMessage/JS-channel origin against the resolved intent.
abstract class DriveOriginValidator {
  const DriveOriginValidator();

  /// Strict equality with the intent origin. [intentClient] is kept for API
  /// compatibility and is not trusted as an origin.
  bool isValid(
    String? origin, {
    required String intentOrigin,
    required String? intentClient,
  }) {
    // Opaque and wildcard origins never identify the Drive page.
    if (origin == null || origin == 'null' || origin == '*') return false;
    return origin == intentOrigin;
  }
}

/// Web: `event.origin` is stamped by the browser and must equal the intent
/// origin exactly. No wildcard, no opaque ('null') origin.
class WebDriveOriginValidator extends DriveOriginValidator {
  const WebDriveOriginValidator();
}

/// Mobile: the origin is read natively from the WebView's current URL, never
/// from what the page claims, and must equal the intent origin exactly.
class MobileDriveOriginValidator extends DriveOriginValidator {
  const MobileDriveOriginValidator();
}
