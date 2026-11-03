@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/platform/web/web_window_message_mixin.dart';
import 'package:universal_html/html.dart' as html;

/// A same-origin iframe that posts [payload] to its parent once loaded. The
/// browser stamps the real `source`, which cannot be forged from a test.
html.IFrameElement _talkingFrame(String payload) {
  final frame = html.IFrameElement()
    ..style.display = 'none'
    ..srcdoc = '<script>parent.postMessage("$payload", "*")</script>';
  html.document.body!.append(frame);
  addTearDown(frame.remove);
  return frame;
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 300));

void main() {
  group('startWebWindowMessageListener expectedFrame', () {
    test('forwards messages posted by the expected iframe only', () async {
      final received = <String>[];
      final trusted = _talkingFrame('from-trusted');
      _talkingFrame('from-other');
      final stop = startWebWindowMessageListener(
        (data, origin) => received.add(data),
        expectedFrame: () => trusted,
      );
      addTearDown(stop);

      await _settle();

      expect(received, ['from-trusted']);
    });

    test(
      'drops everything while the expected frame is not known yet',
      () async {
        final received = <String>[];
        _talkingFrame('early');
        final stop = startWebWindowMessageListener(
          (data, origin) => received.add(data),
          expectedFrame: () => null,
        );
        addTearDown(stop);

        await _settle();

        expect(received, isEmpty);
      },
    );

    test('drops messages posted by the page itself', () async {
      final received = <String>[];
      final frame = html.IFrameElement()..style.display = 'none';
      html.document.body!.append(frame);
      addTearDown(frame.remove);
      final stop = startWebWindowMessageListener(
        (data, origin) => received.add(data),
        expectedFrame: () => frame,
      );
      addTearDown(stop);

      html.window.postMessage('forged-by-parent', '*');
      await _settle();

      expect(received, isEmpty);
    });

    test('without expectedFrame every window is accepted (legacy)', () async {
      final received = <String>[];
      _talkingFrame('anyone');
      final stop = startWebWindowMessageListener(
        (data, origin) => received.add(data),
      );
      addTearDown(stop);

      await _settle();

      expect(received, ['anyone']);
    });

    test('the stop function removes the listener', () async {
      final received = <String>[];
      final frame = _talkingFrame('late');
      final stop = startWebWindowMessageListener(
        (data, origin) => received.add(data),
        expectedFrame: () => frame,
      );
      stop();

      await _settle();

      expect(received, isEmpty);
    });
  });
}
