// ignore_for_file: deprecated_member_use
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/twake_drive_picker.dart' as current;
import 'package:twake_drive_picker/twake_workplace_protocol.dart' as legacy;

void main() {
  test('the deprecated entry point re-exports the public API', () {
    expect(legacy.DriveDocument, same(current.DriveDocument));
    expect(
      legacy.DrivePickerLocalizations.supportedLocales,
      current.DrivePickerLocalizations.supportedLocales,
    );
  });

  test('the old AppLocalizations name is an alias', () {
    expect(legacy.AppLocalizations.supportedLocales, isNotEmpty);
    expect(
      legacy.AppLocalizations.delegate,
      same(current.DrivePickerLocalizations.delegate),
    );
  });
}
