import 'package:floating_toolbar/src/popup.dart';
import 'package:flutter/material.dart';
import 'package:iconic_button/iconic_button.dart';

/// Used in conjunction with [FloatingToolbar.toolbarStyle] to build
/// [IconicButton] for toolbar that is selected or unSelected based on toolbar
/// button taps.
class IconicItem {
  IconicItem({
    required this.iconData,
    this.onPressed,
    this.label,
    this.tooltip,
  });

  /// IconData must be supplied as IconicButton always shows an icon.
  final IconData iconData;

  /// Optional onPressed callback is not used in standard [FloatingToolbarItem]
  final VoidCallback? onPressed;

  /// Optional button label displayed below icon
  final String? label;

  /// Optional tooltip displayed on long press of hover
  final String? tooltip;
}

/// The types of toolbar items [FloatingToolbar] accepts.
/// 
/// buttonOnly: Places an unmanaged [IconicButton] in a [FloatingToolbar]
/// popup: Places an [IconicItem] with an associated list of [PopupItemBuilder]
/// in a [FloatingToolbar] which manages item selection.
/// custom: Places an unmanaged [Widget] in a [FloatingToolbar]
enum FloatingToolbarItemType { buttonOnly, popup, custom }

class FloatingToolbarItem {

  /// Used to make a FloatingToolbarItem of type [FloatingToolbarItemType.popup].
  /// 
  /// [popupItem] : [IconicItem] from which [FloatingToolbar] will build a button.
  /// [popups] : List of [PopupItemBuilder] assoticated with [popupItem].
  /// 
  /// Selection of this button is handled by [FloatingToolbar]. 
  /// Do not use this constructor if you want to control the appearance changes of this button.
  FloatingToolbarItem.popup(
    IconicItem popupItem,
    List<PopupItemBuilder> popups,
  )   : this.type = FloatingToolbarItemType.popup,
        this._popupItem = popupItem,
        this._popups = popups,
        this._basicButton = null,
        this._custom = null;

  /// Used to insert an unmanaged [IconicButton], [basicButton], into the [FloatingToolbar].
  /// This button's selection is not controlled by [FloatingToolbar] and 
  /// has no associated popups.
  FloatingToolbarItem.basic(IconicButton basicButton)
      : this.type = FloatingToolbarItemType.buttonOnly,
        this._basicButton = basicButton,
        this._custom = null,
        this._popupItem = null,
        this._popups = null;

  /// Used to insert an unmanaged Widget, [custom], into the [FloatingToolbar].
  /// Do not use unbounded widgets.
  FloatingToolbarItem.custom(Widget custom)
      : this._custom = custom,
        this.type = FloatingToolbarItemType.custom,
        this._basicButton = null,
        this._popups = null,
        this._popupItem = null;

  /// The type of [FloatingToolbarItem]. Set through choice of constructor.
  final FloatingToolbarItemType type;

  /// IconicItem used in standard mode to build radio button style toolbar
  /// button
  final IconicItem? _popupItem;
  IconicItem get popupItem {
    assert(type == FloatingToolbarItemType.popup);
    return _popupItem!;
  }

  /// List of PopupItemBuilders used to build a [Flex] of popup buttons
  /// associated with a radio button style toolbar button
  final List<PopupItemBuilder>? _popups;
  List<PopupItemBuilder> get popups {
    assert(type == FloatingToolbarItemType.popup);
    return _popups!;
  }

  /// For use when no popups are to be associated with this toolbar button
  final IconicButton? _basicButton;
  IconicButton get basicButton {
    assert(type == FloatingToolbarItemType.buttonOnly);
    return _basicButton!;
  }

  final Widget? _custom;
  Widget get custom {
    assert(type == FloatingToolbarItemType.custom);
    return _custom!;
  }
}