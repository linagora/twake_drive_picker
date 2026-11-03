import 'package:flutter/widgets.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/picker/drive_pick_outcome.dart';
import 'package:twake_drive_picker/src/platform/drive_picker_platform.dart';
import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';

/// The Drive picker without a dialog: loads the intent page into a WebView
/// (mobile) or iframe (web) that fills its parent, and reports through
/// [onResult] and [onClose]. Put it in your own bottom sheet, page or route.
///
/// [DriveIntentWebViewModal] is this view inside the dialog Tmail uses.
///
/// [onResult] is called once with the outcome (picked, cancelled or failed);
/// [onClose] is called right after, for every outcome, so the host can
/// dismiss whatever contains the view. The close button of the loading overlay
/// reports a cancel.
///
/// [imageAssets] is optional: without it the loading overlay is a spinner and
/// the close button a Material icon. [iconButtonBuilder] only applies when
/// [imageAssets] is given.
class DriveIntentWebView extends StatelessWidget {
  final DriveIntentLoader intentLoader;
  final WorkplaceFilePickerConfigRequest filePickerConfig;
  final DriveIntentImageAssets? imageAssets;
  final DriveIconButtonBuilder iconButtonBuilder;
  final WorkplaceLogger logger;
  final DrivePickerPlatform? platform;
  final ValueChanged<DrivePickOutcome>? onResult;
  final VoidCallback? onClose;

  const DriveIntentWebView({
    super.key,
    required this.intentLoader,
    required this.filePickerConfig,
    this.imageAssets,
    this.iconButtonBuilder = defaultDriveIconButtonBuilder,
    this.logger = const NoopWorkplaceLogger(),
    this.platform,
    this.onResult,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) =>
      (platform ?? DrivePickerPlatform.current).buildView(
        intentLoader: intentLoader,
        filePickerConfig: filePickerConfig,
        imageAssets: imageAssets,
        iconButtonBuilder: iconButtonBuilder,
        logger: logger,
        onResult: onResult,
        onClose: onClose,
      );
}
