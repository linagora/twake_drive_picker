import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Look and behaviour the picker asks of an icon button.
class DriveIconButtonSpec {
  final String icon;
  final Color iconColor;
  final Color? hoverColor;
  final double? size;
  final double? iconSize;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const DriveIconButtonSpec({
    required this.icon,
    required this.iconColor,
    this.hoverColor,
    this.size,
    this.iconSize,
    this.padding = const EdgeInsets.all(8),
    this.onTap,
  });
}

/// Lets the host app draw the picker's icon buttons with its own widget.
typedef DriveIconButtonBuilder = Widget Function(DriveIconButtonSpec spec);

Widget defaultDriveIconButtonBuilder(DriveIconButtonSpec spec) => SizedBox(
  width: spec.size,
  height: spec.size,
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: spec.onTap,
    child: Padding(
      padding: spec.padding,
      child: SvgPicture.asset(
        spec.icon,
        width: spec.iconSize,
        height: spec.iconSize,
        colorFilter: ColorFilter.mode(spec.iconColor, BlendMode.srcIn),
      ),
    ),
  ),
);
