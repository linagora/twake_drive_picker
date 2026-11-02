import 'package:flutter/widgets.dart';
import 'package:twake_drive_picker/src/l10n/drive_picker_localizations.dart';

/// The picker strings for [context], never null.
///
/// Falls back to English when the host registered no delegate, or its locale
/// is not one the package ships (the delegate reports those as unsupported, so
/// [DrivePickerLocalizations.of] would return null).
DrivePickerLocalizations resolveDrivePickerLocalizations(
  BuildContext context,
) =>
    DrivePickerLocalizations.of(context) ??
    lookupDrivePickerLocalizations(const Locale('en'));
