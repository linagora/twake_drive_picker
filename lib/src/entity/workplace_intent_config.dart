import 'package:equatable/equatable.dart';

import 'workplace_action_config.dart';
import 'workplace_file_picker_tab.dart';
import 'workplace_theme.dart';

/// The picker shape an intent asks Drive for: which actions to offer and how
/// to render them.
class WorkplaceIntentConfig extends Equatable {
  final WorkplaceActionConfig addAsLink;

  /// Null hides the attachment button.
  final WorkplaceActionConfig? addAsAttachment;
  final WorkplaceTheme theme;

  /// Whether several items can be selected. Null keeps Drive's default (true).
  final bool? multiple;

  /// Folder the picker opens in, on the Drive tab. Null keeps Drive's default
  /// (the root). Drive resolves it on its own instance only; an unknown id
  /// falls back to the root unless [restrictToDefaultDir] is true.
  final String? defaultDirId;

  /// Restricts navigation and selection to [defaultDirId] and shows only the
  /// Drive tab. Null keeps Drive's default (false). Drive fails the intent
  /// when this is true without a [defaultDirId], or with [tabs] other than
  /// `drive`.
  final bool? restrictToDefaultDir;

  /// Tabs to show. Null keeps Drive's default (all of them). Drive fails the
  /// intent on an empty list and shows the tabs in its own order, not the
  /// list's.
  final List<WorkplaceFilePickerTab>? tabs;

  const WorkplaceIntentConfig({
    required this.addAsLink,
    this.addAsAttachment,
    required this.theme,
    this.multiple,
    this.defaultDirId,
    this.restrictToDefaultDir,
    this.tabs,
  });

  @override
  List<Object?> get props => [
    addAsLink,
    addAsAttachment,
    theme,
    multiple,
    defaultDirId,
    restrictToDefaultDir,
    tabs,
  ];
}
