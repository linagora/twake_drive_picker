import 'dart:convert';

import '../entity/drive_document.dart';

/// Called with the reason when an entry of a `done` message is dropped.
/// Never carries a link or a token.
typedef OnDocumentSkipped = void Function(String reason);

/// Parses a message posted by the Drive picker for [intentId].
///
/// Throws [FormatException] when [raw] is not a JSON object. A message of
/// another intent, or of an unknown kind, is a [WorkplaceIntentUnknownMessage].
///
/// Links are accepted over `https` only; [allowInsecureLinks] also accepts
/// `http` (local backends).
WorkplaceIntentMessage parseWorkplaceIntentMessage(
  String intentId,
  String raw, {
  bool allowInsecureLinks = false,
  OnDocumentSkipped? onSkipped,
}) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'Workplace intent message is not a JSON object',
    );
  }
  final rawType = decoded['type'];
  final prefix = 'intent-$intentId:';
  final kind = rawType is String && rawType.startsWith(prefix)
      ? rawType.substring(prefix.length)
      : null;
  return switch (kind) {
    'ready' => const WorkplaceIntentReadyMessage(),
    'readyToUse' => const WorkplaceIntentReadyToUseMessage(),
    'done' => WorkplaceIntentDoneMessage.fromJson(
      decoded,
      allowInsecureLinks: allowInsecureLinks,
      onSkipped: onSkipped,
    ),
    'error' => const WorkplaceIntentErrorMessage(),
    'cancel' => const WorkplaceIntentCancelMessage(),
    _ => WorkplaceIntentUnknownMessage(rawType is String ? rawType : ''),
  };
}

sealed class WorkplaceIntentMessage {
  const WorkplaceIntentMessage();

  factory WorkplaceIntentMessage.parse(
    String intentId,
    String raw, {
    bool allowInsecureLinks = false,
    OnDocumentSkipped? onSkipped,
  }) => parseWorkplaceIntentMessage(
    intentId,
    raw,
    allowInsecureLinks: allowInsecureLinks,
    onSkipped: onSkipped,
  );
}

final class WorkplaceIntentReadyMessage extends WorkplaceIntentMessage {
  const WorkplaceIntentReadyMessage();
}

final class WorkplaceIntentReadyToUseMessage extends WorkplaceIntentMessage {
  const WorkplaceIntentReadyToUseMessage();
}

final class WorkplaceIntentErrorMessage extends WorkplaceIntentMessage {
  const WorkplaceIntentErrorMessage();
}

final class WorkplaceIntentCancelMessage extends WorkplaceIntentMessage {
  const WorkplaceIntentCancelMessage();
}

final class WorkplaceIntentUnknownMessage extends WorkplaceIntentMessage {
  final String type;
  const WorkplaceIntentUnknownMessage(this.type);
}

final class WorkplaceIntentDoneMessage extends WorkplaceIntentMessage {
  final List<DriveDocument> documents;
  const WorkplaceIntentDoneMessage(this.documents);

  factory WorkplaceIntentDoneMessage.fromJson(
    Map<String, dynamic> json, {
    bool allowInsecureLinks = false,
    OnDocumentSkipped? onSkipped,
  }) {
    final raw = json['document'];
    final documents = <DriveDocument>[];
    for (final entry in raw is List ? raw : const []) {
      final document = _validDocument(
        entry,
        allowInsecureLinks: allowInsecureLinks,
        onSkipped: onSkipped,
      );
      if (document != null) documents.add(document);
    }
    return WorkplaceIntentDoneMessage(documents);
  }

  static DriveDocument? _validDocument(
    Object? entry, {
    required bool allowInsecureLinks,
    OnDocumentSkipped? onSkipped,
  }) {
    final DriveDocument document;
    try {
      document = DriveDocument.fromJson(entry as Map<String, dynamic>);
    } on FormatException {
      onSkipped?.call('malformed document entry');
      return null;
    } on TypeError {
      onSkipped?.call('malformed document entry');
      return null;
    }
    bool isSafe(Uri? uri) =>
        uri == null || _isSafeLink(uri, allowInsecureLinks: allowInsecureLinks);
    final reason = _rejectionReason(document, isSafe);
    if (reason != null) {
      onSkipped?.call('skipping doc ${document.id}: $reason');
      return null;
    }
    return _withSafeThumbnail(document, isSafe);
  }

  static String? _rejectionReason(
    DriveDocument document,
    bool Function(Uri?) isSafe,
  ) {
    if (document.id.trim().isEmpty) return 'blank id';
    if (document.name.trim().isEmpty) return 'blank name';
    if (document.size < 0) return 'negative size';
    if (document.sharingLink == null && document.downloadLink == null) {
      return 'no link';
    }
    if (!isSafe(document.sharingLink)) return 'unsafe sharing link';
    if (!isSafe(document.downloadLink)) return 'unsafe download link';
    return null;
  }

  /// An unsafe thumbnail removes only the thumbnail, never the document.
  static DriveDocument _withSafeThumbnail(
    DriveDocument document,
    bool Function(Uri?) isSafe,
  ) {
    if (isSafe(document.thumbnail?.link)) return document;
    return DriveDocument(
      id: document.id,
      name: document.name,
      size: document.size,
      mimeType: document.mimeType,
      sharingLink: document.sharingLink,
      downloadLink: document.downloadLink,
    );
  }

  static bool _isSafeLink(Uri uri, {required bool allowInsecureLinks}) {
    if (uri.host.isEmpty) return false;
    return uri.isScheme('https') ||
        (allowInsecureLinks && uri.isScheme('http'));
  }
}
