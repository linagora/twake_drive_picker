import 'package:twake_drive_picker/src/bridge/cozy_bridge_transport.dart';

/// Selected off the browser: there is no cozy external bridge.
CozyBridgeTransport createDefaultCozyBridgeTransport() =>
    const UnsupportedCozyBridgeTransport();
