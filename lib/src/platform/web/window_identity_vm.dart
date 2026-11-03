import 'package:universal_html/html.dart' as html;

/// Non-browser fallback (universal_html's in-memory DOM): plain equality.
bool isMessageFromFrame(html.MessageEvent event, html.IFrameElement frame) {
  final source = event.source;
  return source != null && source == frame.contentWindow;
}
