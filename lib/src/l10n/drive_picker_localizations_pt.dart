// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'drive_picker_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class DrivePickerLocalizationsPt extends DrivePickerLocalizations {
  DrivePickerLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get addAsLink => 'Adicionar como link';

  @override
  String get addAsAttachment => 'Adicionar como anexo';

  @override
  String get attachFromDriveFailingMessage =>
      'Não foi possível anexar o(s) arquivo(s) do Drive';

  @override
  String get attachFromDrive => 'Anexar do Drive';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class DrivePickerLocalizationsPtBr extends DrivePickerLocalizationsPt {
  DrivePickerLocalizationsPtBr() : super('pt_BR');

  @override
  String get addAsLink => 'Adicionar como link';

  @override
  String get addAsAttachment => 'Adicionar como anexo';

  @override
  String get attachFromDriveFailingMessage =>
      'Não foi possível anexar o(s) arquivo(s) do Drive';

  @override
  String get attachFromDrive => 'Anexar do Drive';
}
