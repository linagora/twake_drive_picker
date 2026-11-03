import 'package:flutter/material.dart';

/// Loading overlay that needs no image asset: a spinner and the close button.
/// Used when the host gives no `DriveIntentImageAssets`.
class DriveIntentPlainLoader extends StatelessWidget {
  final Widget? closeButton;

  const DriveIntentPlainLoader({super.key, this.closeButton});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Stack(
        children: [
          const Center(child: CircularProgressIndicator()),
          if (closeButton != null)
            Positioned(top: 12, right: 17, child: closeButton!),
        ],
      ),
    );
  }
}
