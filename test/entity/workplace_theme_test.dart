import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/entity/workplace_theme.dart';
import 'package:twake_drive_picker/src/model/workplace_enums.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';

void main() {
  group('WorkplaceThemeConfigRequest.fromEntity', () {
    test('maps each theme to its wire type', () {
      expect(
        WorkplaceThemeConfigRequest.fromEntity(WorkplaceTheme.light).type,
        WorkplaceThemeType.light,
      );
      expect(
        WorkplaceThemeConfigRequest.fromEntity(WorkplaceTheme.dark).type,
        WorkplaceThemeType.dark,
      );
    });

    test('serializes the type name for Drive', () {
      expect(
        WorkplaceThemeConfigRequest.fromEntity(WorkplaceTheme.dark).toJson(),
        {'type': 'dark'},
      );
    });
  });
}
