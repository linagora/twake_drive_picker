import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_skeleton_loader.dart';

const _closeButtonKey = ValueKey('close-button');
const _skeletonKey = ValueKey('desktop-skeleton');
const _imageAssets = DriveIntentImageAssets(
  driveLogo: 'assets/images/twake-drive-logo.svg',
  closeIcon: 'assets/images/ic_close.svg',
  searchIcon: 'assets/images/ic_search_bar.svg',
);

void main() {
  testWidgets('desktop loading close button matches the design', (
    tester,
  ) async {
    var closeCalls = 0;
    final closeButton = GestureDetector(
      key: _closeButtonKey,
      onTap: () => closeCalls++,
      child: Container(width: 40, height: 40, color: Colors.transparent),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            key: _skeletonKey,
            width: 800,
            height: 500,
            child: DriveIntentSkeletonLoader.table(
              imageAssets: _imageAssets,
              closeButton: closeButton,
              iconButtonBuilder: (_) => const SizedBox(width: 40, height: 40),
            ),
          ),
        ),
      ),
    );

    final closeButtonFinder = find.byKey(_closeButtonKey);
    final closeContainerFinder = find.descendant(
      of: closeButtonFinder,
      matching: find.byType(Container),
    );
    final skeletonRect = tester.getRect(find.byKey(_skeletonKey));
    final closeRect = tester.getRect(closeContainerFinder);

    expect(closeRect.size, const Size(40, 40));
    expect(closeRect.top, skeletonRect.top + 12);
    expect(closeRect.right, skeletonRect.right - 17);

    await tester.tap(closeContainerFinder);
    expect(closeCalls, 1);
  });
}
