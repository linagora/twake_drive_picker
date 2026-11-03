import 'package:equatable/equatable.dart';
import '../domain/exceptions/workplace_exceptions.dart';
import '../entity/drive_document.dart';
import '../message/workplace_intent_message.dart';

/// Result the Drive picker dialog is popped with.
sealed class DrivePickOutcome extends Equatable {
  const DrivePickOutcome();
}

final class DrivePickOutcomePicked extends DrivePickOutcome {
  final List<DriveDocument> documents;
  const DrivePickOutcomePicked(this.documents);

  @override
  List<Object> get props => [documents];
}

final class DrivePickOutcomeCancelled extends DrivePickOutcome {
  const DrivePickOutcomeCancelled();

  @override
  List<Object> get props => [];
}

final class DrivePickOutcomeFailed extends DrivePickOutcome {
  final Object error;
  const DrivePickOutcomeFailed(this.error);

  @override
  List<Object> get props => [error];
}

/// What a message of the Drive page means for the host, or null when it is
/// only part of the handshake (`ready`, `readyToUse`, unknown types).
///
/// A `done` that yields no usable document is never a successful pick:
/// nothing selected is a cancel, everything rejected is a failure.
DrivePickOutcome? drivePickOutcomeOfMessage(WorkplaceIntentMessage message) =>
    switch (message) {
      WorkplaceIntentDoneMessage(:final documents, :final skippedCount) =>
        documents.isNotEmpty
            ? DrivePickOutcomePicked(documents)
            : skippedCount == 0
            ? const DrivePickOutcomeCancelled()
            : DrivePickOutcomeFailed(DriveIntentNoValidDocumentException()),
      WorkplaceIntentErrorMessage() => DrivePickOutcomeFailed(
        DriveIntentErrorException(),
      ),
      WorkplaceIntentCancelMessage() => const DrivePickOutcomeCancelled(),
      _ => null,
    };
