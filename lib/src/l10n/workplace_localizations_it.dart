// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'workplace_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get addAsLink => 'Aggiungi come collegamento';

  @override
  String get addAsAttachment => 'Aggiungi come allegato';

  @override
  String get attachFromDriveFailingMessage =>
      'Impossibile allegare file da Drive';

  @override
  String get attachFromDrive => 'Allega da Drive';
}
