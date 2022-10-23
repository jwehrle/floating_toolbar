import 'package:floating_toolbar/src/popup.dart';
import 'package:flutter/material.dart';
import 'package:iconic_button/button.dart';

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
enum FloatingToolbarItemType { basic, popup, custom }

class FloatingToolbarItem {
  final FloatingToolbarItemType type;

  /// Used to make a toolbar button that controls associated popups. Selection
  /// of this button is handled by [FloatingToolbar]. Do not use this
  /// constructor if you want to control the appearance changes of this button.
  FloatingToolbarItem.popup(
    IconicItem popupButton,
    List<PopupItemBuilder> popups,
  )   : this.type = FloatingToolbarItemType.popup,
        this._popupButton = popupButton,
        this._popups = popups,
        this._basicButton = null,
        this._custom = null;

  /// Used to insert a custom button into the [FloatingToolbar]. This button's
  /// selection is not controlled by [FloatingToolbar] and has no associated
  /// popups.
  FloatingToolbarItem.basic(IconicButton basicButton)
      : this.type = FloatingToolbarItemType.basic,
        this._basicButton = basicButton,
        this._custom = null,
        this._popupButton = null,
        this._popups = null;

  /// Used to make a completely custom button with no popups. Do not use
  /// unbounded widgets.
  FloatingToolbarItem.custom(Widget custom)
      : this._custom = custom,
        this.type = FloatingToolbarItemType.custom,
        this._basicButton = null,
        this._popups = null,
        this._popupButton = null;

  /// IconicItem used in standard mode to build radio button style toolbar
  /// button
  final IconicItem? _popupButton;
  IconicItem get popupButton {
    assert(type == FloatingToolbarItemType.popup);
    return _popupButton!;
  }

  /// List of PopupItemBuilders used to build a [Flex] of popup buttons
  /// associated with a radio button style toolbar button
  final List<PopupItemBuilder>? _popups;
  List<PopupItemBuilder> get popups {
    assert(type == FloatingToolbarItemType.popup);
    return _popups!;
  }

  /// If true, [_basicButton] is not null but both [_popupButton] and [_popups]
  /// are null. If false, both [_popupButton] and [_popups] are not null but
  /// [_basicButton] is null.

  /// For use when no popups are to be associated with this toolbar button
  final IconicButton? _basicButton;
  IconicButton get basicButton {
    assert(type == FloatingToolbarItemType.basic);
    return _basicButton!;
  }

  final Widget? _custom;
  Widget get custom {
    assert(type == FloatingToolbarItemType.custom);
    return _custom!;
  }
}
