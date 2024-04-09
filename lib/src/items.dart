import 'package:floating_toolbar/src/popup.dart';
import 'package:flutter/material.dart';
import 'package:iconic_button/iconic_button.dart';

/// Used in conjunction with [FloatingToolbar.toolbarStyle] to build
/// [IconicButton] for toolbar that is selected or unSelected based on toolbar
/// button taps.
class IconicItem {
  IconicItem({
    required this.iconData,
    this.label,
    this.isSelectable = true,
    this.tooltip,
  });

  /// IconData must be supplied as IconicButton always shows an icon.
  final IconData iconData;

  /// Optional button label displayed below icon
  final String? label;

  /// Whether this button has a distinct state when selected. Used for
  /// [FloatingToolbarItemType.buttonOnly], defaults to true.
  final bool isSelectable;

  /// Optional tooltip displayed on long press of hover
  final String? tooltip;
}

/// The types of toolbar items [FloatingToolbar] accepts.
///
/// buttonOnly: Places an unmanaged [IconicButton] in a [FloatingToolbar]
/// popup: Places an [IconicItem] with an associated list of [PopupItemBuilder]
/// in a [FloatingToolbar] which manages item selection.
/// custom: Places an unmanaged [Widget] in a [FloatingToolbar]
enum FloatingToolbarItemType { buttonOnly, buttonWithPopups, customButton }

class FloatingToolbarItem {
  /// Used to make a FloatingToolbarItem of type [FloatingToolbarItemType.buttonWithPopups].
  ///
  /// [item] : [IconicItem] from which [FloatingToolbar] will build a button.
  /// [popups] : List of [PopupItemBuilder] assoticated with [item].
  ///
  /// Selection of this button is handled by [FloatingToolbar].
  /// Do not use this constructor if you want to control the appearance changes of this button.
  FloatingToolbarItem.buttonWithPopups({
    required IconicItem item,
    required List<PopupItemBuilder> popups,
  })  : this.type = FloatingToolbarItemType.buttonWithPopups,
        this._buttonWithPopupsItem = item,
        this._popups = popups,
        this._buttonOnlyItem = null,
        this._buttonOnlyController = null,
        this._customButton = null;

  /// Used to insert an unmanaged [IconicButton], [item], into the [FloatingToolbar].
  /// This button's selection is not controlled by [FloatingToolbar] and
  /// has no associated popups.
  FloatingToolbarItem.buttonOnly({
    required IconicItem item,
    required ButtonController controller,
  })  : this.type = FloatingToolbarItemType.buttonOnly,
        this._buttonOnlyItem = item,
        this._buttonOnlyController = controller,
        this._customButton = null,
        this._buttonWithPopupsItem = null,
        this._popups = null;

  /// Used to insert an unmanaged Widget, [custom], into the [FloatingToolbar].
  /// Do not use unbounded widgets.
  FloatingToolbarItem.customButton(Widget custom)
      : this._customButton = custom,
        this.type = FloatingToolbarItemType.customButton,
        this._buttonOnlyItem = null,
        this._buttonOnlyController = null,
        this._popups = null,
        this._buttonWithPopupsItem = null;

  /// The type of [FloatingToolbarItem]. Set through choice of constructor.
  final FloatingToolbarItemType type;

  /// IconicItem used in standard mode to build radio button style toolbar
  /// button
  final IconicItem? _buttonWithPopupsItem;
  IconicItem get buttonWithPopupsItem {
    assert(type == FloatingToolbarItemType.buttonWithPopups);
    return _buttonWithPopupsItem!;
  }

  /// List of PopupItemBuilders used to build a [Flex] of popup buttons
  /// associated with a radio button style toolbar button
  final List<PopupItemBuilder>? _popups;
  List<PopupItemBuilder> get popups {
    assert(type == FloatingToolbarItemType.buttonWithPopups);
    return _popups!;
  }

  /// For use when no popups are to be associated with this toolbar button
  final IconicItem? _buttonOnlyItem;
  IconicItem get buttonOnlyItem {
    assert(type == FloatingToolbarItemType.buttonOnly);
    return _buttonOnlyItem!;
  }

  final ButtonController? _buttonOnlyController;
  ButtonController get buttonOnlyController {
    assert(type == FloatingToolbarItemType.buttonOnly, '');
    return _buttonOnlyController!;
  }

  final Widget? _customButton;
  Widget get customButton {
    assert(type == FloatingToolbarItemType.customButton);
    return _customButton!;
  }
}
