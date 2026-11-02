import 'dart:collection';
import 'dart:convert';

import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_shims.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';
import 'package:twake_drive_picker/src/picker/drive_origin_validator.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_fake_page.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_skeleton_loader.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_web_view_modal_shell.dart';
import 'package:flutter/material.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent.dart';
import 'package:twake_drive_picker/src/domain/exceptions/workplace_exceptions.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';

class DriveIntentWebViewModal extends StatefulWidget {
  final DriveIntentLoader intentLoader;
  final WorkplaceFilePickerConfigRequest filePickerConfig;
  final DriveIntentImageAssets imageAssets;
  final DriveIconButtonBuilder iconButtonBuilder;
  final WorkplaceLogger logger;

  const DriveIntentWebViewModal({
    super.key,
    required this.intentLoader,
    required this.filePickerConfig,
    required this.imageAssets,
    this.iconButtonBuilder = defaultDriveIconButtonBuilder,
    this.logger = const NoopWorkplaceLogger(),
  });

  @override
  State<DriveIntentWebViewModal> createState() =>
      _DriveIntentWebViewModalState();
}

class _DriveIntentWebViewModalState extends State<DriveIntentWebViewModal>
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
    if (intent.intentUrl.scheme == 'data') {
      return _webViewController!.loadData(
        data: DriveIntentFakePage.buildHtml(intent.intentId),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      left: false,
      right: false,
      bottom: false,
      child: DriveIntentWebViewModalShell(
        insetPadding: EdgeInsets.zero,
        constraints: const BoxConstraints.expand(),
        shape: const RoundedRectangleBorder(),
        closeIconPath: widget.imageAssets.closeIcon,
        iconButtonBuilder: widget.iconButtonBuilder,
        onClose: cancel,
        onBarrierTap: () {
          if (!showSkeleton) cancel();
        },
        loadingWidget: showSkeleton
            ? (closeButton) => DriveIntentSkeletonLoader.list(
                imageAssets: widget.imageAssets,
                iconButtonBuilder: widget.iconButtonBuilder,
                closeButton: closeButton,
              )
            : null,
        child: InAppWebView(
          key: const ValueKey('drive-intent-webview'),
          initialSettings: InAppWebViewSettings(),
          initialUserScripts: UnmodifiableListView([
            UserScript(
              source: DriveIntentShims.parentPostMessageShim,
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
            ),
          ]),
          onWebViewCreated: (controller) {
            _webViewController = controller;
            controller.addJavaScriptHandler(
              handlerName: DriveIntentShims.handlerName,
              callback: (args) => onMessage(
                raw: args[0] as String,
                origin: args.length > 1 ? args[1] as String? : null,
              ),
            );
            notifyPlatformViewReady();
          },
          onReceivedError: _handleLoadError,
          onReceivedHttpError: _handleHttpError,
        ),
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
