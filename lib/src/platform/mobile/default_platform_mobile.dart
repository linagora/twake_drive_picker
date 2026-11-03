import 'package:twake_drive_picker/src/platform/drive_picker_platform.dart';
import 'package:twake_drive_picker/src/platform/mobile/mobile_drive_picker_platform.dart';

DrivePickerPlatform createDefaultDrivePickerPlatform() =>
    const MobileDrivePickerPlatform();
