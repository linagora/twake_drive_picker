import 'package:twake_drive_picker/src/bridge/cozy_bridge_transport.dart';
import 'package:twake_drive_picker/src/platform/web/web_cozy_bridge_transport.dart';

/// Selected in the browser.
CozyBridgeTransport createDefaultCozyBridgeTransport() =>
    const WebCozyBridgeTransport();
