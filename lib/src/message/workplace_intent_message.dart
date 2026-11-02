import 'dart:convert';

import 'package:twake_drive_picker/src/logging/workplace_log.dart';

import '../entity/drive_document.dart';

WorkplaceIntentMessage parseWorkplaceIntentMessage(
  String intentId,
  String raw,
) {
  final map = jsonDecode(raw) as Map<String, dynamic>;
  final type = map['type'] as String? ?? '';
  return switch (type) {
    _ when type == 'intent-$intentId:ready' =>
      const WorkplaceIntentReadyMessage(),
    _ when type == 'intent-$intentId:readyToUse' =>
      const WorkplaceIntentReadyToUseMessage(),
    _ when type == 'intent-$intentId:done' =>
      WorkplaceIntentDoneMessage.fromJson(map),
    _ when type == 'intent-$intentId:error' =>
      const WorkplaceIntentErrorMessage(),
    _ when type == 'intent-$intentId:cancel' =>
      const WorkplaceIntentCancelMessage(),
    _ => WorkplaceIntentUnknownMessage(type),
  };
}

sealed class WorkplaceIntentMessage {
  const WorkplaceIntentMessage();

  factory WorkplaceIntentMessage.parse(String intentId, String raw) =>
      parseWorkplaceIntentMessage(intentId, raw);
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

  /// Entries of the message that were dropped as malformed or unsafe.
  final int skippedCount;

  const WorkplaceIntentDoneMessage(this.documents, {this.skippedCount = 0});

  factory WorkplaceIntentDoneMessage.fromJson(Map<String, dynamic> json) {
    final raw = json['document'] as List? ?? [];
    final documents = <DriveDocument>[];
    for (final e in raw) {
      final doc = _tryParseDocument(e);
      if (doc != null) documents.add(doc);
    }
    return WorkplaceIntentDoneMessage(
      documents,
      skippedCount: raw.length - documents.length,
    );
  }

  // Skip reasons are logged without the document id or any error text: both
  // are page-controlled and may carry file metadata.
  static DriveDocument? _tryParseDocument(dynamic e) {
    try {
      final doc = DriveDocument.fromJson(e as Map<String, dynamic>);
      if (doc.size < 0) {
        log('driveIntent: skipping document with negative size');
        return null;
      }
      if (_hasUnsafeUrl(doc)) {
        log('driveIntent: skipping document with non-http(s) URL scheme');
        return null;
      }
      return doc;
    } catch (err) {
      log(
        'driveIntent: skipping malformed document entry (${err.runtimeType})',
      );
      return null;
    }
  }

  static bool _hasUnsafeUrl(DriveDocument doc) {
    for (final uri in [doc.sharingLink, doc.downloadLink]) {
      if (uri == null) continue;
      if (uri.scheme != 'http' && uri.scheme != 'https') return true;
    }
    return false;
  }
}
