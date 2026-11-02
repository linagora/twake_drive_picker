// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'workplace_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get addAsLink => 'إضافة كرابط';

  @override
  String get addAsAttachment => 'إضافة كمرفق';

  @override
  String get attachFromDriveFailingMessage =>
      'تعذر إرفاق ملف/ملفات من محرك الأقراص';

  @override
  String get attachFromDrive => 'إرفاق من Drive';
}
