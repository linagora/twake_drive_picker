import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'drive_picker_localizations_ar.dart';
import 'drive_picker_localizations_de.dart';
import 'drive_picker_localizations_en.dart';
import 'drive_picker_localizations_fr.dart';
import 'drive_picker_localizations_it.dart';
import 'drive_picker_localizations_mn.dart';
import 'drive_picker_localizations_pt.dart';
import 'drive_picker_localizations_ru.dart';
import 'drive_picker_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of DrivePickerLocalizations
/// returned by `DrivePickerLocalizations.of(context)`.
///
/// Applications need to include `DrivePickerLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/drive_picker_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: DrivePickerLocalizations.localizationsDelegates,
///   supportedLocales: DrivePickerLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the DrivePickerLocalizations.supportedLocales
/// property.
abstract class DrivePickerLocalizations {
  DrivePickerLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static DrivePickerLocalizations? of(BuildContext context) {
    return Localizations.of<DrivePickerLocalizations>(
      context,
      DrivePickerLocalizations,
    );
  }

  static const LocalizationsDelegate<DrivePickerLocalizations> delegate =
      _DrivePickerLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
    Locale('mn'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('vi'),
  ];

  /// No description provided for @addAsLink.
  ///
  /// In en, this message translates to:
  /// **'Add as link'**
  String get addAsLink;

  /// No description provided for @addAsAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add as attachment'**
  String get addAsAttachment;

  /// No description provided for @attachFromDriveFailingMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to attach file(s) from drive'**
  String get attachFromDriveFailingMessage;

  /// No description provided for @attachFromDrive.
  ///
  /// In en, this message translates to:
  /// **'Attach from Drive'**
  String get attachFromDrive;
}

class _DrivePickerLocalizationsDelegate
    extends LocalizationsDelegate<DrivePickerLocalizations> {
  const _DrivePickerLocalizationsDelegate();

  @override
  Future<DrivePickerLocalizations> load(Locale locale) {
    return SynchronousFuture<DrivePickerLocalizations>(
      lookupDrivePickerLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'fr',
    'it',
    'mn',
    'pt',
    'ru',
    'vi',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_DrivePickerLocalizationsDelegate old) => false;
}

DrivePickerLocalizations lookupDrivePickerLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return DrivePickerLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return DrivePickerLocalizationsAr();
    case 'de':
      return DrivePickerLocalizationsDe();
    case 'en':
      return DrivePickerLocalizationsEn();
    case 'fr':
      return DrivePickerLocalizationsFr();
    case 'it':
      return DrivePickerLocalizationsIt();
    case 'mn':
      return DrivePickerLocalizationsMn();
    case 'pt':
      return DrivePickerLocalizationsPt();
    case 'ru':
      return DrivePickerLocalizationsRu();
    case 'vi':
      return DrivePickerLocalizationsVi();
  }

  throw FlutterError(
    'DrivePickerLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
