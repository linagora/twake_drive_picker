/// Old entry point of this package (named `twake_workplace_protocol` before
/// 0.2.0). Kept for one release so existing imports keep compiling.
@Deprecated(
  "Import 'package:twake_drive_picker/twake_drive_picker.dart' instead. "
  'This entry point is removed in the next release.',
)
library;

import 'src/l10n/drive_picker_localizations.dart';

export 'twake_drive_picker.dart';

/// Old name of [DrivePickerLocalizations].
@Deprecated('Use DrivePickerLocalizations.')
typedef AppLocalizations = DrivePickerLocalizations;
