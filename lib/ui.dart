/// Widgets and platform code of the Drive picker: the dialog modal used by
/// Tmail, the shell, the state and message mixins, the localizations and the
/// mobile (WebView) / web (iframe) platforms.
///
/// Builds on `core.dart`; import both, or just `twake_drive_picker.dart`.
library;

export 'src/l10n/drive_picker_localizations.dart';
export 'src/l10n/drive_picker_localizations_resolver.dart';
export 'src/platform/drive_picker_platform.dart';
export 'src/platform/web_exports_stub.dart' if (dart.library.html) 'web.dart';
export 'src/presentation/mixin/drive_intent_message_handler_mixin.dart';
export 'src/presentation/mixin/drive_picker_state_mixin.dart';
export 'src/presentation/model/drive_icon_button.dart';
export 'src/presentation/model/drive_intent_image_assets.dart';
export 'src/presentation/model/drive_pick_state.dart';
export 'src/presentation/model/drive_picker_session.dart';
export 'src/presentation/view/drive_intent_skeleton_loader.dart';
export 'src/presentation/view/drive_intent_web_view.dart';
export 'src/presentation/view/drive_intent_web_view_modal.dart';
export 'src/presentation/view/drive_intent_web_view_modal_shell.dart';
