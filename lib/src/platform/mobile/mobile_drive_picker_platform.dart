import 'package:flutter/widgets.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/platform/drive_picker_platform.dart';
import 'package:twake_drive_picker/src/platform/mobile/drive_intent_web_view_modal_mobile.dart';
import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';

/// Android / iOS: Drive runs in a `flutter_inappwebview`. There is no cozy
/// external bridge and no browser window outside of it.
class MobileDrivePickerPlatform extends DrivePickerPlatform {
  const MobileDrivePickerPlatform();

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

  @override
  StopWindowMessageListener listenToWindowMessages(
    WindowMessageCallback onMessage, {
    Object? Function()? expectedFrame,
  }) => () {};

  @override
  Widget buildModal({
    required DriveIntentLoader intentLoader,
    required WorkplaceFilePickerConfigRequest filePickerConfig,
    required DriveIntentImageAssets imageAssets,
    required DriveIconButtonBuilder iconButtonBuilder,
    required WorkplaceLogger logger,
  }) => MobileDriveIntentWebViewModal(
    intentLoader: intentLoader,
    filePickerConfig: filePickerConfig,
    imageAssets: imageAssets,
    iconButtonBuilder: iconButtonBuilder,
    logger: logger,
  );
}
