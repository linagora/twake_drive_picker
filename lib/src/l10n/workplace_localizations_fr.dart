// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'workplace_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get addAsLink => 'Ajouter comme lien';

  @override
  String get addAsAttachment => 'Ajouter comme pièce jointe';

  @override
  String get attachFromDriveFailingMessage =>
      'Impossible de joindre le(s) fichier(s) depuis Drive';

  @override
  String get attachFromDrive => 'Joindre depuis Drive';
}
