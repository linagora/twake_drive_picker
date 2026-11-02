import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_web_view_modal_shell.dart';

const _closeIcon = 'assets/close.svg';

Widget _fakeIconButton(DriveIconButtonSpec spec) => GestureDetector(
  key: const ValueKey('fake-close-button'),
  onTap: spec.onTap,
  child: const SizedBox(width: 40, height: 40),
);

Widget _shell({
  required bool haveCloseButton,
  required BoxConstraints constraints,
  required EdgeInsets insetPadding,
  Widget Function(Widget closeButton)? loadingWidget,
  VoidCallback? onClose,
}) {
  return MaterialApp(
    home: _modalShell(
      haveCloseButton: haveCloseButton,
      constraints: constraints,
      insetPadding: insetPadding,
      loadingWidget: loadingWidget,
      onClose: onClose,
    ),
  );
}

Widget _modalShell({
  required bool haveCloseButton,
  required BoxConstraints constraints,
  required EdgeInsets insetPadding,
  Widget Function(Widget closeButton)? loadingWidget,
  VoidCallback? onClose,
}) {
  return DriveIntentWebViewModalShell(
    closeIconPath: _closeIcon,
    onClose: onClose ?? () {},
    constraints: constraints,
    insetPadding: insetPadding,
    loadingWidget: loadingWidget,
    iconButtonBuilder: _fakeIconButton,
    child: const SizedBox.shrink(),
  );
}

void main() {
  group('DriveIntentWebViewModalShell', () {
    _testLoadingOverlayIsClosable();
    _testLoadingOverlayCloseButtonCallback();
    _testNoPointerInterceptorWithoutLoadingOverlay();
  });
}

void _testLoadingOverlayIsClosable() {
  testWidgets('loading overlay is always closable — receives a close button', (
    tester,
  ) async {
    Widget? received;
    await tester.pumpWidget(
      _shell(
        haveCloseButton: false,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
        insetPadding: const EdgeInsets.all(24),
        loadingWidget: (closeButton) {
          received = closeButton;
          return closeButton;
        },
      ),
    );

    expect(received, isNotNull);
    expect(find.byWidget(received!), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(PointerInterceptor),
        matching: find.byType(Positioned),
      ),
      findsOneWidget,
    );
  });
}

void _testLoadingOverlayCloseButtonCallback() {
  testWidgets('loading overlay close button is wired to onClose', (
    tester,
  ) async {
    var closed = 0;
    Widget? received;
    await tester.pumpWidget(
      _shell(
        haveCloseButton: false,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
        insetPadding: const EdgeInsets.all(24),
        onClose: () => closed++,
        loadingWidget: (closeButton) {
          received = closeButton;
          return closeButton;
        },
      ),
    );

    await tester.tap(find.byWidget(received!));
    expect(closed, 1);
  });
}

void _testNoPointerInterceptorWithoutLoadingOverlay() {
  testWidgets('does not intercept pointers without a loading overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      _shell(
        haveCloseButton: false,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
        insetPadding: const EdgeInsets.all(24),
      ),
    );

    expect(find.byType(PointerInterceptor), findsNothing);
  });
}
