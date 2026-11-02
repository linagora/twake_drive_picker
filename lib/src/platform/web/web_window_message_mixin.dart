import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twake_drive_picker/src/platform/drive_picker_platform.dart';
import 'package:twake_drive_picker/src/platform/web/window_identity.dart';
import 'package:universal_html/html.dart' as html;

typedef OnWebWindowListener = void Function(html.Event);

/// Starts forwarding `window.onmessage` events whose data is a String (or a
/// Map, re-encoded as JSON).
///
/// When [expectedFrame] is given, only events posted by that iframe's window
/// are forwarded; while it returns null (or anything but an iframe) every
/// event is dropped. Returns the function stopping the listener.
StopWindowMessageListener startWebWindowMessageListener(
  WindowMessageCallback onMessage, {
  Object? Function()? expectedFrame,
}) {
  void listener(html.Event event) {
    if (event is! html.MessageEvent) return;
    if (expectedFrame != null) {
      final frame = expectedFrame();
      if (frame is! html.IFrameElement || !isMessageFromFrame(event, frame)) {
        return;
      }
    }
    dynamic data = event.data;
    if (data is Map) {
      data = jsonEncode(data);
    }
    if (data is! String) return;
    onMessage(data, event.origin);
  }

  html.window.addEventListener('message', listener);
  return () => html.window.removeEventListener('message', listener);
}

/// Mixin for [State] subclasses that need to listen to `window.onmessage`
/// events. Guards for [html.MessageEvent] and String data before forwarding.
mixin WebWindowMessageMixin<T extends StatefulWidget> on State<T> {
  StopWindowMessageListener? _stopListener;

  void startWindowMessageListener(
    void Function(String data, String? origin) onMessage, {
    Object? Function()? expectedFrame,
  }) {
    _stopListener?.call();
    _stopListener = startWebWindowMessageListener(
      onMessage,
      expectedFrame: expectedFrame,
    );
  }

  void stopWindowMessageListener() {
    _stopListener?.call();
    _stopListener = null;
  }
}
