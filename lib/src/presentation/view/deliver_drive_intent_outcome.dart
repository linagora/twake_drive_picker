import 'package:flutter/widgets.dart';
import 'package:twake_drive_picker/src/picker/drive_pick_outcome.dart';

/// Reports the outcome, then closes. [onClose] runs even when [onResult]
/// throws, so a faulty handler cannot leave the host's sheet open.
void deliverDriveIntentOutcome(
  DrivePickOutcome outcome, {
  ValueChanged<DrivePickOutcome>? onResult,
  VoidCallback? onClose,
}) {
  try {
    onResult?.call(outcome);
  } finally {
    onClose?.call();
  }
}
