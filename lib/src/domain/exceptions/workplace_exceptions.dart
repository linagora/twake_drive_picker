class WorkplaceCreateIntentException implements Exception {}

class WorkplaceExchangeTokenException implements Exception {}

class DriveIntentErrorException implements Exception {}

class DriveIntentPageLoadException implements Exception {
  final String reason;

  DriveIntentPageLoadException(this.reason);

  @override
  String toString() => 'DriveIntentPageLoadException: $reason';
}

class DriveIntentTimeoutException implements Exception {}

/// Drive reported a pick, but every document was rejected (malformed,
/// negative size or non-http(s) link).
class DriveIntentNoValidDocumentException implements Exception {}

class WorkplaceNoIntentClientException implements Exception {}

/// The caller cancelled the Drive upload; no share link is returned.
class WorkplaceUploadCancelledException implements Exception {}

class DriveDownloadNullAttachmentException implements Exception {}

class DriveDownloadInsecureLinkException implements Exception {}
