import 'package:flutter/widgets.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/platform/drive_picker_platform.dart';
import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';

/// Modal that loads the Drive intent page and pops a `DrivePickOutcome`.
///
/// Delegates to the [DrivePickerPlatform] the app is compiled for (webview on
/// mobile, iframe on web) unless [platform] is given.
class DriveIntentWebViewModal extends StatelessWidget {
  final DriveIntentLoader intentLoader;
  final WorkplaceFilePickerConfigRequest filePickerConfig;
  final DriveIntentImageAssets imageAssets;
  final DriveIconButtonBuilder iconButtonBuilder;
  final WorkplaceLogger logger;
  final DrivePickerPlatform? platform;

  const DriveIntentWebViewModal({
    super.key,
    required this.intentLoader,
    required this.filePickerConfig,
    required this.imageAssets,
    this.iconButtonBuilder = defaultDriveIconButtonBuilder,
    this.logger = const NoopWorkplaceLogger(),
    this.platform,
  });

  @override
  Widget build(BuildContext context) =>
      (platform ?? DrivePickerPlatform.current).buildModal(
        intentLoader: intentLoader,
        filePickerConfig: filePickerConfig,
        imageAssets: imageAssets,
        iconButtonBuilder: iconButtonBuilder,
        logger: logger,
      );
}
