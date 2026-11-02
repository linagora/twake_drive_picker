@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The core of the package must stay usable by a mobile-only host: no web
/// library may be imported outside `platform/web` (and the conditional
/// exports that select it).
void main() {
  final forbidden = RegExp(
    r'''(universal_html|dart:js_interop|dart:js_interop_unsafe|dart:html|dart:js_util|package:web/)''',
  );
  const conditionalSelectors = {
    'lib/src/platform/default_platform.dart',
    'lib/twake_drive_picker.dart',
  };

  List<File> dartFiles(String root) => Directory(root)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('core imports no web-only library', () {
    final offenders = <String>[];
    for (final file in dartFiles('lib')) {
      final path = file.path;
      if (path.startsWith('lib/src/platform/web/') || path == 'lib/web.dart') {
        continue;
      }
      for (final line in file.readAsLinesSync()) {
        final isDirective =
            line.startsWith('import ') || line.startsWith('export ');
        if (isDirective && forbidden.hasMatch(line)) {
          offenders.add('$path: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('only the conditional selectors reference platform/web', () {
    final offenders = <String>[];
    for (final file in dartFiles('lib')) {
      final path = file.path;
      if (path.startsWith('lib/src/platform/web/') ||
          path == 'lib/web.dart' ||
          conditionalSelectors.contains(path)) {
        continue;
      }
      for (final line in file.readAsLinesSync()) {
        final isDirective =
            line.startsWith('import ') || line.startsWith('export ');
        if (isDirective && line.contains('platform/web/')) {
          offenders.add('$path: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('web-only files are only selected behind dart.library.html', () {
    for (final path in conditionalSelectors) {
      final source = File(path).readAsStringSync();
      expect(source, contains('dart.library.html'), reason: path);
    }
  });
}
