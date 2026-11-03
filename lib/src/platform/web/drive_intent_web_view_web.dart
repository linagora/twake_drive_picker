import 'package:twake_drive_picker/src/platform/web/html_iframe_widget.dart';
import 'package:flutter/material.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:universal_html/html.dart' as html;
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent.dart';
import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:twake_drive_picker/src/platform/web/web_window_message_mixin.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';
import 'package:twake_drive_picker/src/picker/drive_origin_validator.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_skeleton_loader.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_plain_loader.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_view_frame.dart';
import 'package:twake_drive_picker/src/presentation/view/deliver_drive_intent_outcome.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_web_view_modal_shell.dart';
import 'package:twake_drive_picker/src/picker/drive_pick_outcome.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';

class WebDriveIntentWebView extends StatefulWidget {
  final DriveIntentLoader intentLoader;
  final WorkplaceFilePickerConfigRequest filePickerConfig;
  final DriveIntentImageAssets? imageAssets;
  final DriveIconButtonBuilder iconButtonBuilder;
  final WorkplaceLogger logger;

  /// True: no dialog, no barrier and no route pop, the outcome goes to
  /// [onResult] and [onClose]. False: the dialog of the modal, which pops it.
  final bool embedded;
  final ValueChanged<DrivePickOutcome>? onResult;
  final VoidCallback? onClose;

  const WebDriveIntentWebView({
    super.key,
    required this.intentLoader,
    required this.filePickerConfig,
    required this.imageAssets,
    this.iconButtonBuilder = defaultDriveIconButtonBuilder,
    this.logger = const NoopWorkplaceLogger(),
    this.embedded = false,
    this.onResult,
    this.onClose,
  }) : assert(
         embedded || imageAssets != null,
         'The dialog needs imageAssets; only the embedded view can go without.',
       );

  @override
  State<WebDriveIntentWebView> createState() => _WebDriveIntentWebViewState();
}

class _WebDriveIntentWebViewState extends State<WebDriveIntentWebView>
    with
        DriveIntentMessageHandlerMixin,
        WebWindowMessageMixin<WebDriveIntentWebView> {
  html.IFrameElement? _iframeElement;

  @override
  WorkplaceLogger get workplaceLogger => widget.logger;

  @override
  DriveOriginValidator get originValidator => const WebDriveOriginValidator();

  static const double _wideScreenMinWidth = 900;

  bool wideScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= _wideScreenMinWidth;
  }

  Widget _loadingWidget({required bool wideScreen, Widget? closeButton}) {
    final assets = widget.imageAssets;
    if (assets == null) return DriveIntentPlainLoader(closeButton: closeButton);
    if (wideScreen) {
      return DriveIntentSkeletonLoader.table(
        imageAssets: assets,
        iconButtonBuilder: widget.iconButtonBuilder,
        closeButton: closeButton,
      );
    }
    return DriveIntentSkeletonLoader.list(
      imageAssets: assets,
      iconButtonBuilder: widget.iconButtonBuilder,
      closeButton: closeButton,
    );
  }

  @override
  bool get popsRouteOnFinish => !widget.embedded;

  @override
  void onFinished(DrivePickOutcome outcome) => deliverDriveIntentOutcome(
    outcome,
    onResult: widget.onResult,
    onClose: widget.onClose,
  );

  HtmlIframeWidget _iframe() => HtmlIframeWidget(
    key: const ValueKey('drive-intent-webview'),
    borderRadius: 6,
    onIframeCreated: (iframe) {
      final viewRecreated =
          _iframeElement != null && !identical(_iframeElement, iframe);
      _iframeElement = iframe;
      notifyPlatformViewReady(viewRecreated: viewRecreated);
    },
  );

  @override
  void initState() {
    super.initState();
    // The modal owns its listener: bound to its own lifetime, not the opener's
    // (the opener may pop its route on tap and be disposed early). Registered
    // before the iframe can post its first ready message.
    // Only the modal's own iframe may speak: other frames and windows of the
    // page can post to us with any origin they like.
    startWindowMessageListener(
      _forwardMessage,
      expectedFrame: () => _iframeElement,
    );
    startLoading(widget.intentLoader);
  }

  @override
  Future<void> loadIntent(WorkplaceIntent intent) async {
    // No web equivalent of mobile's onReceivedError: cross-origin iframes
    // expose no navigation-failure signal, and probing the URL first could
    // false-close on CSP mismatches — readyTimeout is the only safe fallback.
    _iframeElement!.src = intent.intentUrl.toString();
  }

  void _forwardMessage(String raw, String? origin) =>
      onMessage(raw: raw, origin: origin);

  @override
  void onCleanup() {
    stopWindowMessageListener();
  }

  @override
  void dispose() {
    // Guards routes popped outside the finish path (system back, parent nav);
    // onCleanup is idempotent.
    onCleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      // The parent decides the size, so the skeleton follows the space it is
      // given rather than the window.
      return DriveIntentViewFrame(
        closeIconPath: widget.imageAssets?.closeIcon,
        iconButtonBuilder: widget.iconButtonBuilder,
        onClose: cancel,
        loadingWidget: showSkeleton
            ? (closeButton) => LayoutBuilder(
                builder: (_, constraints) => _loadingWidget(
                  wideScreen: constraints.maxWidth >= _wideScreenMinWidth,
                  closeButton: closeButton,
                ),
              )
            : null,
        child: _iframe(),
      );
    }
    final isWideScreen = wideScreen(context);
    final shell = DriveIntentWebViewModalShell(
      insetPadding: isWideScreen ? const EdgeInsets.all(24) : EdgeInsets.zero,
      constraints: isWideScreen
          ? const BoxConstraints(maxWidth: 800, maxHeight: 677)
          : const BoxConstraints.expand(),
      shape: isWideScreen
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
            )
          : const RoundedRectangleBorder(),
      alignment: isWideScreen ? Alignment.center : null,
      closeIconPath: widget.imageAssets!.closeIcon,
      iconButtonBuilder: widget.iconButtonBuilder,
      onClose: cancel,
      onBarrierTap: () {
        if (!showSkeleton) cancel();
      },
      loadingWidget: showSkeleton
          ? (closeButton) => _loadingWidget(
              wideScreen: isWideScreen,
              closeButton: closeButton,
            )
          : null,
      child: _iframe(),
    );
    // Keep the iframe ancestry stable across resize: remounting it reloads Drive.
    return Stack(
      children: [
        Positioned.fill(
          child: PointerInterceptor(child: const SizedBox.expand()),
        ),
        SafeArea(
          top: !isWideScreen,
          left: false,
          right: false,
          bottom: false,
          child: shell,
        ),
      ],
    );
  }

  @override
  Future<void> sendAck() async {
    // Never '*': the ack carries the picker config, so it only goes to the
    // exact origin of the intent page.
    final targetOrigin = intentOrigin;
    // dart:html's postMessage structured-clones the Map into a real JS
    // object, which is what Drive's getFilePickerConfig expects.
    _iframeElement?.contentWindow?.postMessage(
      widget.filePickerConfig.toJson(),
      targetOrigin,
    );
  }
}
