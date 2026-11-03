import 'package:twake_drive_picker/src/bridge/cozy_bridge_transport.dart';
import 'package:twake_drive_picker/src/platform/web/cozy_bridge_web.dart';

/// Browser bridge: requests go through `window._cozyBridge` of the container.
class WebCozyBridgeTransport extends CozyBridgeTransport {
  const WebCozyBridgeTransport();

  @override
  bool get isBridgeSupported => WebCozyBridge.isSupported;

  @override
  bool get isBridgeAvailable => WebCozyBridge.isAvailable;

  @override
  Future<dynamic> fetchJson({
    required String method,
    required String path,
    Object? body,
    Map<String, String>? headers,
  }) => WebCozyBridge.fetchJson(
    method: method,
    path: path,
    body: body,
    headers: headers,
  );
}
