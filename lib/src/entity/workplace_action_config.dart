import 'package:equatable/equatable.dart';

class WorkplaceActionConfig extends Equatable {
  final String? label;
  final num? maxFileSize;
  final num? availableSize;

  /// Whether a folder can be picked for this action. Null keeps Drive's own
  /// default (links allow folders, attachments do not).
  final bool? allowFolder;

  /// What the action accepts: `file`, `folder` and/or mime patterns such as
  /// `image/*`. Null keeps Drive's default. When set, Drive ignores
  /// [allowFolder].
  final List<String>? accept;

  /// Most items that can be picked at once for this action.
  final num? maxFileCount;

  const WorkplaceActionConfig({
    this.label,
    this.maxFileSize,
    this.availableSize,
    this.allowFolder,
    this.accept,
    this.maxFileCount,
  });

  @override
  List<Object?> get props => [
    label,
    maxFileSize,
    availableSize,
    allowFolder,
    accept,
    maxFileCount,
  ];
}
