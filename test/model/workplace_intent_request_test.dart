import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/twake_drive_picker.dart';

void main() {
  group('WorkplaceActionConfigRequest::toJson::', () {
    test('includes maxFileSize and availableSize when both are set', () {
      const request = WorkplaceActionConfigRequest(
        label: 'Attachment',
        maxFileSize: 100,
        availableSize: 100,
      );

      final json = request.toJson();

      expect(json['maxFileSize'], equals(100));
      expect(json['availableSize'], equals(100));
    });

    test('omits maxFileSize and availableSize when both are null', () {
      const request = WorkplaceActionConfigRequest(label: 'Attachment');

      final json = request.toJson();

      expect(json.containsKey('maxFileSize'), isFalse);
      expect(json.containsKey('availableSize'), isFalse);
    });
  });

  group('WorkplaceActionConfigRequest::fromEntity::', () {
    test('copies maxFileSize and availableSize from the domain entity', () {
      const entity = WorkplaceActionConfig(
        label: 'Attachment',
        maxFileSize: 5000,
        availableSize: 5000,
      );

      final request = WorkplaceActionConfigRequest.fromEntity(entity);

      expect(request.label, equals('Attachment'));
      expect(request.maxFileSize, equals(5000));
      expect(request.availableSize, equals(5000));
    });

    test('copies null maxFileSize and availableSize when entity has none', () {
      const entity = WorkplaceActionConfig(label: 'Attachment');

      final request = WorkplaceActionConfigRequest.fromEntity(entity);

      expect(request.maxFileSize, isNull);
      expect(request.availableSize, isNull);
    });
  });

  group('WorkplaceFilePickerConfigRequest::toJson::', () {
    const theme = WorkplaceThemeConfigRequest(type: WorkplaceThemeType.light);

    test('without options the JSON is what Drive always received', () {
      const request = WorkplaceFilePickerConfigRequest(
        sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
        downloadLink: null,
        theme: theme,
      );

      expect(request.toJson(), {
        'sharingLink': {'label': 'Link'},
        'downloadLink': null,
        'theme': {'type': 'light'},
      });
    });

    test('serializes the optional picker options', () {
      const request = WorkplaceFilePickerConfigRequest(
        sharingLink: WorkplaceActionConfigRequest(label: 'Link'),
        downloadLink: null,
        theme: theme,
        multiple: false,
        defaultDirId: 'dir-1',
        restrictToDefaultDir: true,
        tabs: [WorkplaceFilePickerTab.drive, WorkplaceFilePickerTab.recents],
      );

      final json = request.toJson();

      expect(json['multiple'], isFalse);
      expect(json['defaultDirId'], 'dir-1');
      expect(json['restrictToDefaultDir'], isTrue);
      expect(json['tabs'], ['drive', 'recents']);
    });

    test('serializes the optional action options', () {
      const request = WorkplaceActionConfigRequest(
        label: 'Attach',
        allowFolder: false,
        accept: ['image/*', 'application/pdf'],
        maxFileCount: 3,
      );

      expect(request.toJson(), {
        'label': 'Attach',
        'allowFolder': false,
        'accept': ['image/*', 'application/pdf'],
        'maxFileCount': 3,
      });
    });

    test('omits the action options when unset', () {
      final json = const WorkplaceActionConfigRequest(label: 'x').toJson();

      expect(json.keys, ['label']);
    });
  });
}
