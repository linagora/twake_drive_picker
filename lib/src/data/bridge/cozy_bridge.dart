import 'package:twake_drive_picker/src/bridge/cozy_bridge_transport.dart';
import 'package:twake_drive_picker/src/bridge/default_cozy_bridge_transport.dart'
    as default_transport;

/// Proxies requests through the cozy external bridge of the container app.
///
/// Thin facade over the default [CozyBridgeTransport]: only the browser one
/// supports it, so other builds report [isSupported] false.
abstract final class CozyBridge {
  static final CozyBridgeTransport _transport = default_transport
      .createDefaultCozyBridgeTransport();

  static bool get isSupported => _transport.isBridgeSupported;

  static bool get isAvailable => _transport.isBridgeAvailable;

  static Future<dynamic> fetchJson({
    required String method,
    required String path,
    Object? body,
    Map<String, String>? headers,
  }) => _transport.fetchJson(
    method: method,
    path: path,
    body: body,
    headers: headers,
  );
}
