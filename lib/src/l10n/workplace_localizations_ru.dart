// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'workplace_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get addAsLink => 'Добавить как ссылку';

  @override
  String get addAsAttachment => 'Добавить как вложение';

  @override
  String get attachFromDriveFailingMessage =>
      'Не удалось прикрепить файл(ы) с диска';

  @override
  String get attachFromDrive => 'Прикрепить с диска';
}
