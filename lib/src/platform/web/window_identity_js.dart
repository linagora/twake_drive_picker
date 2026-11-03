import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:universal_html/html.dart' as html;

/// Whether [event] was posted by the window of [frame].
///
/// Compared on the raw JS objects: dart:html wraps cross-frame windows in a
/// fresh `_DOMWindowCrossFrame` on every access, so Dart `==` is always false.
bool isMessageFromFrame(html.MessageEvent event, html.IFrameElement frame) {
  final source = (event as JSObject)['source'];
  final frameWindow = (frame as JSObject)['contentWindow'];
  if (source.isUndefinedOrNull || frameWindow.isUndefinedOrNull) return false;
  return source.strictEquals(frameWindow).toDart;
}
