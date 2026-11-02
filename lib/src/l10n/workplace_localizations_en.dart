// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'workplace_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get addAsLink => 'Add as link';

  @override
  String get addAsAttachment => 'Add as attachment';

  @override
  String get attachFromDriveFailingMessage =>
      'Unable to attach file(s) from drive';

  @override
  String get attachFromDrive => 'Attach from Drive';
}
