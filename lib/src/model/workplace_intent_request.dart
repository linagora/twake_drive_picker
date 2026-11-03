import 'workplace_enums.dart';
import 'package:json_annotation/json_annotation.dart';
import '../entity/workplace_action_config.dart';
import '../entity/workplace_file_picker_tab.dart';
import '../entity/workplace_theme.dart';

part 'workplace_intent_request.g.dart';

@JsonSerializable(createFactory: false, includeIfNull: false)
class WorkplaceActionConfigRequest {
  final String? label;
  final num? maxFileSize;
  final num? availableSize;

  /// See [WorkplaceActionConfig.allowFolder].
  final bool? allowFolder;

  /// See [WorkplaceActionConfig.accept].
  final List<String>? accept;

  /// See [WorkplaceActionConfig.maxFileCount].
  final num? maxFileCount;

  const WorkplaceActionConfigRequest({
    this.label,
    this.maxFileSize,
    this.availableSize,
    this.allowFolder,
    this.accept,
    this.maxFileCount,
  });

  factory WorkplaceActionConfigRequest.fromEntity(
    WorkplaceActionConfig config,
  ) => WorkplaceActionConfigRequest(
    label: config.label,
    maxFileSize: config.maxFileSize,
    availableSize: config.availableSize,
    allowFolder: config.allowFolder,
    accept: config.accept,
    maxFileCount: config.maxFileCount,
  );

  Map<String, dynamic> toJson() => _$WorkplaceActionConfigRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class WorkplaceThemeConfigRequest {
  final WorkplaceThemeType type;

  const WorkplaceThemeConfigRequest({required this.type});

  factory WorkplaceThemeConfigRequest.fromEntity(WorkplaceTheme theme) =>
      WorkplaceThemeConfigRequest(
        type: switch (theme) {
          WorkplaceTheme.light => WorkplaceThemeType.light,
          WorkplaceTheme.dark => WorkplaceThemeType.dark,
        },
      );

  Map<String, dynamic> toJson() => _$WorkplaceThemeConfigRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplaceFilePickerConfigRequest {
  final WorkplaceActionConfigRequest sharingLink;
  final WorkplaceActionConfigRequest? downloadLink;
  final WorkplaceThemeConfigRequest theme;

  /// See [WorkplaceIntentConfig.multiple]. Omitted from the JSON when null.
  @JsonKey(includeIfNull: false)
  final bool? multiple;

  /// See [WorkplaceIntentConfig.defaultDirId]. Omitted when null.
  @JsonKey(includeIfNull: false)
  final String? defaultDirId;

  /// See [WorkplaceIntentConfig.restrictToDefaultDir]. Omitted when null.
  @JsonKey(includeIfNull: false)
  final bool? restrictToDefaultDir;

  /// See [WorkplaceIntentConfig.tabs]. Omitted when null.
  @JsonKey(includeIfNull: false)
  final List<WorkplaceFilePickerTab>? tabs;

  const WorkplaceFilePickerConfigRequest({
    required this.sharingLink,
    required this.downloadLink,
    required this.theme,
    this.multiple,
    this.defaultDirId,
    this.restrictToDefaultDir,
    this.tabs,
  });

  Map<String, dynamic> toJson() =>
      _$WorkplaceFilePickerConfigRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplaceIntentAttributesRequest {
  final WorkplaceAction action;
  final WorkplaceDocType type;
  final List<WorkplacePermission> permissions;
  final WorkplaceFilePickerConfigRequest data;

  const WorkplaceIntentAttributesRequest({
    required this.action,
    required this.type,
    required this.permissions,
    required this.data,
  });

  Map<String, dynamic> toJson() =>
      _$WorkplaceIntentAttributesRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplaceIntentDataRequest {
  final WorkplaceDataRequestType type;
  final WorkplaceIntentAttributesRequest attributes;

  const WorkplaceIntentDataRequest({
    required this.type,
    required this.attributes,
  });

  Map<String, dynamic> toJson() => _$WorkplaceIntentDataRequestToJson(this);
}

@JsonSerializable(createFactory: false, explicitToJson: true)
class WorkplaceIntentRequest {
  final WorkplaceIntentDataRequest data;

  const WorkplaceIntentRequest({required this.data});

  Map<String, dynamic> toJson() => _$WorkplaceIntentRequestToJson(this);
}
