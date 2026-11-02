import 'package:flutter/widgets.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/platform/default_platform.dart'
    as default_platform;
import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';

/// Stops a listener started with [DrivePickerPlatform.listenToWindowMessages].
typedef StopWindowMessageListener = void Function();

/// Forwards a `window.postMessage` payload with the browser-stamped origin.
typedef WindowMessageCallback = void Function(String data, String? origin);

/// Everything the picker needs from the host platform.
///
/// The core of the package (domain, data, message, picker) only talks to this
/// interface, so it never imports `dart:html` / `dart:js_interop` /
/// `universal_html`. The mobile implementation lives under `platform/mobile`
/// (flutter_inappwebview), the web one under `platform/web` (iframe +
/// postMessage + cozy external bridge).
abstract class DrivePickerPlatform {
  const DrivePickerPlatform();

  /// The implementation of the platform the app is compiled for. Selected by
  /// a conditional import, so mobile builds never compile the web code.
  static final DrivePickerPlatform current = default_platform
      .createDefaultDrivePickerPlatform();

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

  /// Listens to `window.postMessage` events. When [expectedFrame] is given,
  /// only messages posted by that frame are forwarded. Platforms without a
  /// browser window return a no-op stopper.
  StopWindowMessageListener listenToWindowMessages(
    WindowMessageCallback onMessage, {
    Object? Function()? expectedFrame,
  });

  /// Builds the modal that loads the Drive intent page and reports the outcome
  /// by popping a [DrivePickOutcome].
  Widget buildModal({
    required DriveIntentLoader intentLoader,
    required WorkplaceFilePickerConfigRequest filePickerConfig,
    required DriveIntentImageAssets imageAssets,
    required DriveIconButtonBuilder iconButtonBuilder,
    required WorkplaceLogger logger,
  });
}
