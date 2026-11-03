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
    'lib/src/bridge/default_cozy_bridge_transport.dart',
    'lib/ui.dart',
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

  test('core.dart reaches no widget, WebView or UI file', () {
    final forbiddenCore = RegExp(
      r'''(package:flutter/|flutter_inappwebview|pointer_interceptor|universal_html|src/presentation/|src/platform/(?!web/(default_cozy_bridge_transport_web|web_cozy_bridge_transport|cozy_bridge_web)\.dart)|src/l10n/)''',
    );
    final directive = RegExp(
      r'''(?:import|export)\s+'([^']+)';?|'([^']+\.dart)';''',
    );
    final visited = <String>{};
    final offenders = <String>[];

    void visit(String path) {
      if (!visited.add(path)) return;
      final file = File(path);
      if (!file.existsSync()) return;
      for (final line in file.readAsLinesSync()) {
        final isDirective =
            line.startsWith('import ') ||
            line.startsWith('export ') ||
            line.trimLeft().startsWith('if (dart.library');
        if (!isDirective) continue;
        final uri = directive.firstMatch(line);
        final target = uri?.group(1) ?? uri?.group(2);
        if (target == null) continue;
        if (forbiddenCore.hasMatch(target)) {
          offenders.add('$path -> $target');
          continue;
        }
        if (target.startsWith('dart:') ||
            (target.startsWith('package:') &&
                !target.startsWith('package:twake_drive_picker/'))) {
          continue;
        }
        final resolved = target.startsWith('package:twake_drive_picker/')
            ? 'lib/${target.substring('package:twake_drive_picker/'.length)}'
            : File(path).parent.uri.resolve(target).toFilePath();
        visit(resolved.replaceFirst('${Directory.current.path}/', ''));
      }
    }

    visit('lib/core.dart');
    expect(visited.length, greaterThan(40));
    expect(offenders, isEmpty);
  });
}
