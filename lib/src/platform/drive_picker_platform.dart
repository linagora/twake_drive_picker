import 'package:flutter/widgets.dart';
import 'package:twake_drive_picker/src/bridge/cozy_bridge_transport.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/picker/drive_pick_outcome.dart';
import 'package:twake_drive_picker/src/platform/default_platform.dart'
    as default_platform;
import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';

/// Stops a listener started with [DrivePickerPlatform.listenToWindowMessages].
typedef StopWindowMessageListener = void Function();

/// Forwards a `window.postMessage` payload with the browser-stamped origin.
typedef WindowMessageCallback = void Function(String data, String? origin);

/// Everything the picker UI needs from the host platform, on top of the
/// UI-free [CozyBridgeTransport] the core uses.
///
/// The mobile implementation lives under `platform/mobile`
/// (flutter_inappwebview), the web one under `platform/web` (iframe +
/// postMessage + cozy external bridge). The core never imports this file.
abstract class DrivePickerPlatform extends CozyBridgeTransport {
  const DrivePickerPlatform();

  /// The implementation of the platform the app is compiled for. Selected by
  /// a conditional import, so mobile builds never compile the web code.
  static final DrivePickerPlatform current = default_platform
      .createDefaultDrivePickerPlatform();

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

  /// Builds the dialog-free view: same page and protocol as [buildModal], but
  /// it fills its parent and reports through [onResult] / [onClose] instead of
  /// popping a route. [imageAssets] may be null (spinner instead of skeleton).
  ///
  /// Not abstract, so a platform written before this member existed keeps
  /// compiling: by default it throws an [UnsupportedError]. The built-in
  /// mobile and web platforms override it. A custom platform that wants to
  /// support `DriveIntentWebView` overrides it too.
  Widget buildView({
    required DriveIntentLoader intentLoader,
    required WorkplaceFilePickerConfigRequest filePickerConfig,
    required DriveIntentImageAssets? imageAssets,
    required DriveIconButtonBuilder iconButtonBuilder,
    required WorkplaceLogger logger,
    ValueChanged<DrivePickOutcome>? onResult,
    VoidCallback? onClose,
  }) => throw UnsupportedError(
    '$runtimeType does not implement buildView, so DriveIntentWebView is not '
    'available on it. Override DrivePickerPlatform.buildView, or use '
    'DriveIntentWebViewModal (buildModal) instead.',
  );
}
