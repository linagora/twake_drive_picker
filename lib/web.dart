/// Web platform of the Drive picker (iframe + `postMessage` + cozy bridge).
///
/// Imported by web apps that need the web classes explicitly; non-web apps
/// must not import it, as it pulls in `universal_html` / `dart:js_interop`.
/// `package:twake_drive_picker/twake_drive_picker.dart` already re-exports it
/// on web builds.
library;

export 'src/platform/web/web_drive_picker_platform.dart';
export 'src/platform/web/web_window_message_mixin.dart';
