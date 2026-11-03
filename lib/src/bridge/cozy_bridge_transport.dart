/// How requests reach cozy-stack through the cozy external bridge of a
/// container app.
///
/// UI-free: the data layer only talks to this interface. The browser
/// implementation is selected by a conditional import; everywhere else the
/// bridge is reported as unsupported and every call uses a bearer token.
abstract class CozyBridgeTransport {
  const CozyBridgeTransport();

  /// Whether this platform can reach Drive through a cozy external bridge.
  bool get isBridgeSupported;

  /// Whether the bridge is usable right now (web: inside the container iframe).
  bool get isBridgeAvailable;

  /// Proxies a request through the cozy external bridge.
  ///
  /// Throws [UnsupportedError] when [isBridgeSupported] is false.
  Future<dynamic> fetchJson({
    required String method,
    required String path,
    Object? body,
    Map<String, String>? headers,
  });
}

/// No bridge: mobile, desktop and any host that is not a container app.
class UnsupportedCozyBridgeTransport extends CozyBridgeTransport {
  const UnsupportedCozyBridgeTransport();

  @override
  bool get isBridgeSupported => false;

  @override
  bool get isBridgeAvailable => false;

  @override
  Future<dynamic> fetchJson({
    required String method,
    required String path,
    Object? body,
    Map<String, String>? headers,
  }) => throw UnsupportedError('Cozy bridge is only available on web');
}
