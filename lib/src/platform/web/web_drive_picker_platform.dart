import 'package:flutter/widgets.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/platform/drive_picker_platform.dart';
import 'package:twake_drive_picker/src/platform/web/cozy_bridge_web.dart';
import 'package:twake_drive_picker/src/platform/web/drive_intent_web_view_modal_web.dart';
import 'package:twake_drive_picker/src/platform/web/web_window_message_mixin.dart';
import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';

/// Browser: Drive runs in an iframe, talked to through `postMessage`, and
/// requests can go through the cozy external bridge of the container app.
class WebDrivePickerPlatform extends DrivePickerPlatform {
  const WebDrivePickerPlatform();

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

  @override
  StopWindowMessageListener listenToWindowMessages(
    WindowMessageCallback onMessage, {
    Object? Function()? expectedFrame,
  }) => startWebWindowMessageListener(onMessage, expectedFrame: expectedFrame);

  @override
  Widget buildModal({
    required DriveIntentLoader intentLoader,
    required WorkplaceFilePickerConfigRequest filePickerConfig,
    required DriveIntentImageAssets imageAssets,
    required DriveIconButtonBuilder iconButtonBuilder,
    required WorkplaceLogger logger,
  }) => WebDriveIntentWebViewModal(
    intentLoader: intentLoader,
    filePickerConfig: filePickerConfig,
    imageAssets: imageAssets,
    iconButtonBuilder: iconButtonBuilder,
    logger: logger,
  );
}
