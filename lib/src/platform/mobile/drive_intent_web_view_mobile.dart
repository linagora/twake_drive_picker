import 'dart:collection';
import 'dart:convert';

import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:twake_drive_picker/src/platform/mobile/drive_intent_shims.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';
import 'package:twake_drive_picker/src/picker/drive_origin_validator.dart';
import 'package:twake_drive_picker/src/platform/mobile/mobile_message_gate.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_skeleton_loader.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_plain_loader.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_view_frame.dart';
import 'package:twake_drive_picker/src/presentation/view/deliver_drive_intent_outcome.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_web_view_modal_shell.dart';
import 'package:twake_drive_picker/src/picker/drive_pick_outcome.dart';
import 'package:flutter/material.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent.dart';
import 'package:twake_drive_picker/src/domain/exceptions/workplace_exceptions.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';

class MobileDriveIntentWebView extends StatefulWidget {
  final DriveIntentLoader intentLoader;
  final WorkplaceFilePickerConfigRequest filePickerConfig;
  final DriveIntentImageAssets? imageAssets;
  final DriveIconButtonBuilder iconButtonBuilder;
  final WorkplaceLogger logger;

  /// True: no dialog and no route pop, the outcome goes to [onResult] and
  /// [onClose]. False: the dialog of the modal, which pops the outcome.
  final bool embedded;
  final ValueChanged<DrivePickOutcome>? onResult;
  final VoidCallback? onClose;

  const MobileDriveIntentWebView({
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
  State<MobileDriveIntentWebView> createState() =>
      _MobileDriveIntentWebViewState();
}

class _MobileDriveIntentWebViewState extends State<MobileDriveIntentWebView>
    with DriveIntentMessageHandlerMixin {
  @override
  WorkplaceLogger get workplaceLogger => widget.logger;

  InAppWebViewController? _webViewController;

  @override
  DriveOriginValidator get originValidator =>
      const MobileDriveOriginValidator();

  @override
  void initState() {
    super.initState();
    startLoading(widget.intentLoader);
  }

  @override
  Future<void> loadIntent(WorkplaceIntent intent) {
    return _webViewController!.loadUrl(
      urlRequest: URLRequest(url: WebUri.uri(intent.intentUrl)),
    );
  }

  // Only main-frame failures mean the page is unusable; subframe errors
  // (favicons, trackers) must not kill the picker. Unknown (null) counts as
  // subframe — worst case is falling back to the ready timeout.
  bool _isMainFrame(WebResourceRequest request) =>
      request.isForMainFrame == true;

  void _handleLoadError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    if (!_isMainFrame(request)) return;
    notifyPageLoadFailed(
      DriveIntentPageLoadException('${error.type}: ${error.description}'),
    );
  }

  void _handleHttpError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceResponse errorResponse,
  ) {
    if (!_isMainFrame(request)) return;
    notifyPageLoadFailed(
      DriveIntentPageLoadException('HTTP ${errorResponse.statusCode}'),
    );
  }

  // The page can only be reached at the intent origin: a redirect, a link or
  // a script navigating elsewhere would let foreign content talk to the picker
  // through the same JS handler.
  Future<NavigationActionPolicy> _handleNavigation(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final allowed = isNavigationToIntentOriginAllowed(
      action.request.url?.uriValue,
      intentOrigin: intentOrigin,
    );
    if (!allowed) {
      workplaceLogger.log('driveIntent: blocked navigation to a foreign url');
    }
    return allowed
        ? NavigationActionPolicy.ALLOW
        : NavigationActionPolicy.CANCEL;
  }

  @override
  bool get popsRouteOnFinish => !widget.embedded;

  @override
  void onFinished(DrivePickOutcome outcome) => deliverDriveIntentOutcome(
    outcome,
    onResult: widget.onResult,
    onClose: widget.onClose,
  );

  Widget _loading(Widget closeButton) {
    final assets = widget.imageAssets;
    if (assets == null) return DriveIntentPlainLoader(closeButton: closeButton);
    return DriveIntentSkeletonLoader.list(
      imageAssets: assets,
      iconButtonBuilder: widget.iconButtonBuilder,
      closeButton: closeButton,
    );
  }

  Widget _webView() => InAppWebView(
    key: const ValueKey('drive-intent-webview'),
    initialSettings: InAppWebViewSettings(useShouldOverrideUrlLoading: true),
    initialUserScripts: UnmodifiableListView([
      UserScript(
        source: DriveIntentShims.parentPostMessageShim,
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        forMainFrameOnly: true,
      ),
    ]),
    onWebViewCreated: (controller) {
      _webViewController = controller;
      final gate = MobileMessageGate(
        currentUrl: () async => (await controller.getUrl())?.uriValue,
        onMessage: onMessage,
      );
      controller.addJavaScriptHandler(
        handlerName: DriveIntentShims.handlerName,
        callback: gate.handle,
      );
      notifyPlatformViewReady();
    },
    shouldOverrideUrlLoading: _handleNavigation,
    onReceivedError: _handleLoadError,
    onReceivedHttpError: _handleHttpError,
  );

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return DriveIntentViewFrame(
        closeIconPath: widget.imageAssets?.closeIcon,
        iconButtonBuilder: widget.iconButtonBuilder,
        onClose: cancel,
        loadingWidget: showSkeleton ? _loading : null,
        child: _webView(),
      );
    }
    return SafeArea(
      top: true,
      left: false,
      right: false,
      bottom: false,
      child: DriveIntentWebViewModalShell(
        insetPadding: EdgeInsets.zero,
        constraints: const BoxConstraints.expand(),
        shape: const RoundedRectangleBorder(),
        closeIconPath: widget.imageAssets!.closeIcon,
        iconButtonBuilder: widget.iconButtonBuilder,
        onClose: cancel,
        onBarrierTap: () {
          if (!showSkeleton) cancel();
        },
        loadingWidget: showSkeleton ? _loading : null,
        child: _webView(),
      ),
    );
  }

  @override
  Future<void> sendAck() async {
    if (!isValidDriveClient(intentClient)) {
      throw WorkplaceNoIntentClientException();
    }
    // Embedded unquoted: JSON object syntax is valid JS object-literal syntax,
    // so `event.data` in the page ends up a real object, not a JSON string —
    // Drive's getFilePickerConfig never calls JSON.parse on it.
    final payload = jsonEncode(widget.filePickerConfig.toJson());
    await _webViewController?.evaluateJavascript(
      source:
          '''
      window.dispatchEvent(new MessageEvent('message', {
        data: $payload,
        origin: ${jsonEncode(intentClient)},
        source: window
      }));
    ''',
    );
  }
}
