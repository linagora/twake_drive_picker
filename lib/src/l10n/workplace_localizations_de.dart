// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'workplace_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get addAsLink => 'Als Link hinzufügen';

  @override
  String get addAsAttachment => 'Als Anhang hinzufügen';

  @override
  String get attachFromDriveFailingMessage =>
      'Datei(en) von Drive konnten nicht angehängt werden';

  @override
  String get attachFromDrive => 'Von Drive anhängen';
}
