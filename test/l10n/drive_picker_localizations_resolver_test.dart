import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/l10n/drive_picker_localizations.dart';
import 'package:twake_drive_picker/src/l10n/drive_picker_localizations_resolver.dart';

Future<DrivePickerLocalizations> _resolveIn(
  WidgetTester tester, {
  Locale? locale,
  bool withDelegates = true,
}) async {
  late DrivePickerLocalizations resolved;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: [
        if (withDelegates) ...DrivePickerLocalizations.localizationsDelegates,
        if (!withDelegates) ...[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
      ],
      supportedLocales: const [Locale('en'), Locale('es'), Locale('fr')],
      home: Builder(
        builder: (context) {
          resolved = resolveDrivePickerLocalizations(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  // The framework warns that a delegate lacks the host locale; resolving
  // must work regardless, which is what these tests assert.
  tester.takeException();
  return resolved;
}

void main() {
  final english = lookupDrivePickerLocalizations(const Locale('en'));
  final french = lookupDrivePickerLocalizations(const Locale('fr'));

  testWidgets('uses the host locale when the package ships it', (tester) async {
    final l10n = await _resolveIn(tester, locale: const Locale('fr'));

    expect(l10n.addAsLink, french.addAsLink);
    expect(l10n.addAsLink, isNot(english.addAsLink));
  });

  testWidgets('falls back to English for a locale the package lacks', (
    tester,
  ) async {
    final l10n = await _resolveIn(tester, locale: const Locale('es'));

    expect(
      DrivePickerLocalizations.delegate.isSupported(const Locale('es')),
      isFalse,
    );
    expect(l10n.addAsLink, english.addAsLink);
    expect(
      l10n.attachFromDriveFailingMessage,
      english.attachFromDriveFailingMessage,
    );
  });

  testWidgets('falls back to English when the delegate is not registered', (
    tester,
  ) async {
    final l10n = await _resolveIn(
      tester,
      locale: const Locale('fr'),
      withDelegates: false,
    );

    expect(l10n.addAsLink, english.addAsLink);
  });

  test('every shipped locale resolves to its own strings', () {
    for (final locale in DrivePickerLocalizations.supportedLocales) {
      expect(
        lookupDrivePickerLocalizations(locale).localeName,
        locale.toString(),
      );
    }
  });
}
