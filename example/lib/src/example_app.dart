import 'package:flutter/material.dart';
import 'package:twake_drive_picker/twake_drive_picker.dart';

/// Where the example reaches Twake Workplace. Set with `--dart-define`:
///
///   flutter run -t lib/main_mobile.dart \
///     --dart-define=PLATFORM_URL=https://alice.example.com \
///     --dart-define=OIDC_TOKEN=ID_TOKEN
///
/// On web, inside the Twake container app, no token is needed: the cozy
/// bridge is used.
const _platformUrl = String.fromEnvironment('PLATFORM_URL');
const _oidcToken = String.fromEnvironment('OIDC_TOKEN');

const _assets = DriveIntentImageAssets(
  driveLogo: 'assets/images/drive_logo.svg',
  closeIcon: 'assets/images/ic_close.svg',
  searchIcon: 'assets/images/ic_search.svg',
);

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key, required this.platformLabel});

  /// Shown on the page, to tell the two entry points apart.
  final String platformLabel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drive picker example',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      // The picker's strings live in its own delegate: register it.
      localizationsDelegates: DrivePickerLocalizations.localizationsDelegates,
      supportedLocales: DrivePickerLocalizations.supportedLocales,
      home: PickerPage(platformLabel: platformLabel),
    );
  }
}

class PickerPage extends StatefulWidget {
  const PickerPage({super.key, required this.platformLabel});

  final String platformLabel;

  @override
  State<PickerPage> createState() => _PickerPageState();
}

class _PickerPageState extends State<PickerPage> with DrivePickerStateMixin {
  String _status = 'Nothing picked yet';

  // One config for the whole app: its Dio is reused by every request.
  final _config = WorkplaceConfig();

  @override
  DrivePickerSession get session => DrivePickerSession(
    uploadFromUrlSupported: () => true,
    maxAttachmentSizeBytesGetter: () => 25 * 1024 * 1024,
    remainingAttachmentCapacityBytesGetter: () => null,
    onFetchIntent: _fetchIntent,
  );

  @override
  DriveIntentImageAssets get driveIntentImageAssets => _assets;

  @override
  OnPickDriveCallback? get pickerOnCallback => (state) async {
    if (!mounted) return;
    setState(() {
      _status = switch (state) {
        DrivePickResult(:final documents) =>
          'Picked ${documents.length} document(s): '
              '${documents.map((d) => d.name).join(', ')}',
        DrivePickFailure(:final error) => 'Failed: ${error.runtimeType}',
        DrivePickSuccess() => 'Done',
      };
    });
  };

  Future<WorkplaceIntent> _fetchIntent({
    required WorkplaceFilePickerConfigRequest filePickerConfig,
  }) {
    final platformUrl = Uri.parse(_platformUrl);
    final repository = WorkplaceRepositoryImpl(
      WorkplaceDataSourceImpl(config: _config),
      WorkplaceDriveDataSourceImpl(
        executor: WorkplaceRequestExecutor(config: _config),
      ),
    );
    final runner = WorkplaceAccessModeRunner(
      exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
      oidcTokenGetter: () => _oidcToken.isEmpty ? null : _oidcToken,
      // The example has no way to refresh the OIDC token.
      oidcRefreshTrigger: () async => null,
    );
    return runner.run(
      platformUrl,
      CreateDriveIntentCall(
        CreateDriveIntentInteractor(repository),
        platformUrl,
        _toIntentConfig(filePickerConfig),
      ),
    );
  }

  WorkplaceIntentConfig _toIntentConfig(WorkplaceFilePickerConfigRequest c) =>
      WorkplaceIntentConfig(
        addAsLink: WorkplaceActionConfig(label: c.sharingLink.label),
        addAsAttachment: c.downloadLink == null
            ? null
            : WorkplaceActionConfig(
                label: c.downloadLink!.label,
                maxFileSize: c.downloadLink!.maxFileSize,
                availableSize: c.downloadLink!.availableSize,
              ),
        theme: c.theme.type == WorkplaceThemeType.dark
            ? WorkplaceTheme.dark
            : WorkplaceTheme.light,
      );

  @override
  Widget build(BuildContext context) {
    final configured = _platformUrl.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text('Drive picker - ${widget.platformLabel}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: configured ? onPickerTap : null,
                child: const Text('Pick from Drive'),
              ),
              const SizedBox(height: 16),
              Text(
                configured
                    ? _status
                    : 'Run with --dart-define=PLATFORM_URL=https://<your cozy>',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
