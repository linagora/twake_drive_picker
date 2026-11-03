abstract final class DriveIntentShims {
  static const String handlerName = 'driveIntentMessage';

  /// Makes the Drive page's `window.parent.postMessage(data, ...)` reach the
  /// Flutter handler.
  ///
  /// Only the payload is forwarded. The `targetOrigin` the page passes is
  /// page-controlled and therefore worthless as a sender identity: the origin
  /// is read natively from the WebView instead (see `MobileMessageGate`).
  /// Sub-frames are left alone, so a frame embedded by the page does not get
  /// the fake parent.
  static String get parentPostMessageShim =>
      '''
    (function() {
      if (window.self !== window.top) return;
      window.parent = {
        postMessage: function(data) {
          window.flutter_inappwebview.callHandler(
            '$handlerName',
            typeof data === 'string' ? data : JSON.stringify(data)
          );
        }
      };
    })();
    ''';
}
