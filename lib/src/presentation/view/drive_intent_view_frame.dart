import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';

/// Builds the close button of the picker. With a [closeIconPath] it goes
/// through [iconButtonBuilder] (the host's own button); without one it is a
/// plain Material close icon, so no asset is needed.
Widget buildDriveCloseButton({
  required String? closeIconPath,
  required DriveIconButtonBuilder iconButtonBuilder,
  required VoidCallback onClose,
}) {
  const iconColor = Color(0xA3424244); // 0xFF424244 at 64% opacity
  if (closeIconPath != null) {
    return iconButtonBuilder(
      DriveIconButtonSpec(
        icon: closeIconPath,
        size: 40,
        iconSize: 24,
        iconColor: iconColor,
        hoverColor: const Color(0x14424244),
        onTap: onClose,
      ),
    );
  }
  return SizedBox(
    width: 40,
    height: 40,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClose,
      child: const Icon(Icons.close, size: 24, color: iconColor),
    ),
  );
}

/// The picker content (WebView / iframe) with the loading overlay on top of
/// it. No dialog, no route: it fills whatever space its parent gives it, which
/// is what lets the host put it in its own sheet or page.
class DriveIntentViewFrame extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  /// Icon of the close button, or null for the built-in Material one.
  final String? closeIconPath;
  final DriveIconButtonBuilder iconButtonBuilder;

  /// Overlay shown while Drive loads; receives the close button.
  final Widget Function(Widget closeButton)? loadingWidget;

  const DriveIntentViewFrame({
    super.key,
    required this.child,
    required this.onClose,
    this.closeIconPath,
    this.iconButtonBuilder = defaultDriveIconButtonBuilder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final closeButton = buildDriveCloseButton(
      closeIconPath: closeIconPath,
      iconButtonBuilder: iconButtonBuilder,
      onClose: onClose,
    );
    return Stack(
      children: [
        KeyedSubtree(key: const ValueKey('drive-shell-content'), child: child),
        if (loadingWidget != null)
          Positioned.fill(
            child: PointerInterceptor(child: loadingWidget!(closeButton)),
          ),
      ],
    );
  }
}
