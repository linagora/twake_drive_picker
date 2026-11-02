import 'package:twake_drive_picker/src/platform/drive_picker_platform.dart';

/// Proxies requests through the cozy external bridge of the container app.
///
/// Thin facade over the current [DrivePickerPlatform]: only the web platform
/// supports it, so mobile builds report [isSupported] false.
abstract final class CozyBridge {
  static bool get isSupported => DrivePickerPlatform.current.isBridgeSupported;

  static bool get isAvailable => DrivePickerPlatform.current.isBridgeAvailable;

  static Future<dynamic> fetchJson({
    required String method,
    required String path,
    Object? body,
    Map<String, String>? headers,
  }) => DrivePickerPlatform.current.fetchJson(
    method: method,
    path: path,
    body: body,
    headers: headers,
  );
}
