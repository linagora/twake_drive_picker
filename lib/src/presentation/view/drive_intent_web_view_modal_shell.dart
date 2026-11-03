import 'package:flutter/material.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_view_frame.dart';

class DriveIntentWebViewModalShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;
  // Tap outside the dialog card (the backdrop). Defaults to [onClose], but
  // must stay disabled while loading — unlike the close button, which should
  // always work — so callers pass a guarded callback here when needed.
  final VoidCallback? onBarrierTap;
  final EdgeInsets insetPadding;
  final ShapeBorder? shape;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Widget Function(Widget closeButton)? loadingWidget;
  final DriveIconButtonBuilder iconButtonBuilder;
  final String closeIconPath;

  const DriveIntentWebViewModalShell({
    super.key,
    required this.child,
    required this.onClose,
    required this.closeIconPath,
    this.onBarrierTap,
    this.insetPadding = const EdgeInsets.all(0),
    this.shape,
    this.constraints,
    this.alignment,
    this.loadingWidget,
    this.iconButtonBuilder = defaultDriveIconButtonBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBarrierTap ?? onClose,
      behavior: HitTestBehavior.opaque,
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: insetPadding,
        shape: shape,
        constraints: constraints,
        alignment: alignment,
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: DriveIntentViewFrame(
            onClose: onClose,
            closeIconPath: closeIconPath,
            iconButtonBuilder: iconButtonBuilder,
            loadingWidget: loadingWidget,
            child: child,
          ),
        ),
      ),
    );
  }
}
