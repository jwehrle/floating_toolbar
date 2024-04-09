import 'package:floating_toolbar/src/widgets/toolbar_button.dart';
import 'package:floating_toolbar/src/widgets/popup_list.dart';
import 'package:flutter/material.dart';

/// Enum of Flutter-supplied ShapeBorders
enum ButtonShape {
  circle,
  roundedRectangle,
  continuousRectangle,
  beveledRectangle,
  stadium,
}

/// Single enum combining Alignment and Axis.
enum ToolbarAlignment {
  topLeftVertical,
  centerLeftVertical,
  bottomLeftVertical,
  topLeftHorizontal,
  topCenterHorizontal,
  topRightHorizontal,
  topRightVertical,
  centerRightVertical,
  bottomRightVertical,
  bottomLeftHorizontal,
  bottomCenterHorizontal,
  bottomRightHorizontal,
}

/// Encapsulates toolbar parameters into an object
class ToolbarData {
  ToolbarData({
    required this.alignment,
    required this.backgroundColor,
    required this.buttonSize,
    this.contentPadding = const EdgeInsets.all(2.0),
    this.buttonSpacing = 2.0,
    this.popupSpacing = 2.0,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(4.0),
      ),
    ),
    this.margin = const EdgeInsets.all(2.0),
    this.clip = Clip.antiAlias,
    this.elevation = 2.0,
  });

  /// The location of the toolbar. The first direction indicates alignment along
  /// a side, the second direction indicates alignment relative to that side.
  /// For example: leftTop means the toolbar will be placed vertically along the
  /// left side, and, the start of the toolbar will be at the top.
  final ToolbarAlignment alignment;

  /// The background color of the toolbar
  final Color backgroundColor;

  /// The padding around the buttons but not between them. Default is 2.0 on
  /// all sides.
  final EdgeInsets contentPadding;

  /// The padding between buttons in the toolbar. Default is 2.0
  final double buttonSpacing;

  /// The padding between popups in the toolbar. Default is 2.0
  final double popupSpacing;

  /// The ShapeBorder of the toolbar. Default is Rounded Rectangle with
  /// BorderRadius of 4.0 on all corners.
  final ShapeBorder shape;

  /// Padding around the toolbar. Default is 2.0 on all sides.
  final EdgeInsets margin;

  /// The Clip behavior to assign to the ScrollView the toolbar is wrapped in.
  /// Default is antiAlias.
  final Clip clip;

  /// The elevation of the Material widget the toolbar is wrapped in. Default is
  /// 2.0
  final double elevation;

  /// The Size of the buttons in the toolbar. Used with a SizedBox so if using
  /// widgets that may overflow this size make sure to wrap in FittedBox
  final Size buttonSize;

  @override
  String toString() {
    return 'ToolbarData: ToolbarAlignment $alignment, color $backgroundColor, '
        'content padding $contentPadding, button spacing $buttonSpacing, shape '
        '$shape, margin $margin, clip $clip, elevation $elevation, button size: '
        '$buttonSize';
  }

  @override
  int get hashCode {
    int hash = backgroundColor.hashCode;
    hash %= contentPadding.hashCode;
    hash %= buttonSpacing.hashCode;
    hash %= shape.hashCode;
    hash %= margin.hashCode;
    hash %= clip.hashCode;
    hash %= elevation.hashCode;
    hash %= buttonSize.hashCode;
    return hash;
  }

  @override
  bool operator ==(Object other) {
    if (other is ToolbarData) {
      if (backgroundColor != other.backgroundColor) {
        return false;
      }
      if (contentPadding != other.contentPadding) {
        return false;
      }
      if (buttonSpacing != other.buttonSpacing) {
        return false;
      }
      if (shape != other.shape) {
        return false;
      }
      if (margin != other.margin) {
        return false;
      }
      if (clip != other.clip) {
        return false;
      }
      if (elevation != other.elevation) {
        return false;
      }
      if (buttonSize != other.buttonSize) {
        return false;
      }
      return true;
    }
    return false;
  }
}

/// Encapsulates builders for types of buttons used by FloatingToolbar. Enforces
/// choice between pop and noPop. Pop requires PopupButtonBuilder and
/// PopupListBuilder. NoPop requires SelectableButtonBuilder. Both constructors
/// require itemKey.
class ToolbarItem {
  final String itemKey;
  final PopupButtonBuilder? _popupButtonBuilder;
  final SelectableButtonBuilder? _selectableButtonBuilder;
  final PopupListBuilder? _popupListBuilder;
  final bool isPopup;

  /// Used for buttons that show a list of popup buttons when selected.
  ToolbarItem.pop({
    required this.itemKey,
    required PopupButtonBuilder popupButtonBuilder,
    required PopupListBuilder popupListBuilder,
  })  : this._popupButtonBuilder = popupButtonBuilder,
        this._popupListBuilder = popupListBuilder,
        _selectableButtonBuilder = null,
        isPopup = true;

  /// Used for buttons that do not show a list of popup buttons when selected.
  ToolbarItem.noPop({
    required this.itemKey,
    required SelectableButtonBuilder selectableButtonBuilder,
  })  : this._selectableButtonBuilder = selectableButtonBuilder,
        _popupButtonBuilder = null,
        _popupListBuilder = null,
        isPopup = false;

  /// Returns the popupButtonBuilder of this item or throws an error if this
  /// item is noPop
  PopupButtonBuilder get popupButtonBuilder =>
      isPopup ? _popupButtonBuilder! : throw ('ToolbarItem is noPopup');

  /// Returns the popupListBuilder of this item or throws an error if this
  /// item is noPop
  PopupListBuilder get popupListBuilder =>
      isPopup ? _popupListBuilder! : throw ('ToolbarItem is noPopup');

  /// Returns the SelectableButtonBuilder of this item or throws an error if
  /// this item is pop
  SelectableButtonBuilder get selectableButtonBuilder =>
      isPopup ? throw ('ToolbarItem is Popup') : _selectableButtonBuilder!;

  @override
  String toString() => itemKey;

  @override
  int get hashCode => itemKey.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ToolbarItem ? itemKey == other.itemKey : false;
}

/// Encapsulates parameters needed by PopupListData from FloatingToolbar.
class PopupListData {
  final String itemKey;
  final LayerLink link;
  final ValueNotifier<String?> selectionNotifier;
  final EdgeInsets spacing;
  final Axis direction;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;

  PopupListData({
    required this.itemKey,
    required this.link,
    required this.selectionNotifier,
    required this.spacing,
    required this.direction,
    required this.targetAnchor,
    required this.followerAnchor,
    required this.offset,
  });
}

typedef PopupListBuilder = PopupList Function(PopupListData data);

/// Encapsulates parameters needed by PopupButton from FloatingToolbar.
class PopupButtonData {
  /// The string associated by user with this button. Should be unique.
  final String itemKey;

  /// Builds the popups associated with this button
  final PopupListBuilder popupListBuilder;

  /// ValueNotifier for itemKeys of FloatingToolbar
  final ValueNotifier<String?> selectionNotifier;

  /// The size of this button
  final Size size;

  /// Callback for taps on buttons, passes itemKey
  final ValueChanged<String?>? onSelectionChanged;

  /// Spacing between popups
  final EdgeInsets popupSpacing;

  /// Axis of popup buttons which is opposite of toolbar axis
  final Axis popupDirection;

  /// Anchor point of button relative to PopupList
  final Alignment targetAnchor;

  /// Anchor point of PopupList relative button
  final Alignment followerAnchor;

  /// Offset of PopupList from button
  final Offset followerOffset;

  PopupButtonData({
    required this.itemKey,
    required this.popupListBuilder,
    required this.selectionNotifier,
    required this.size,
    required this.onSelectionChanged,
    required this.popupSpacing,
    required this.popupDirection,
    required this.targetAnchor,
    required this.followerAnchor,
    required this.followerOffset,
  });
}

/// Builder for PopupButtons
typedef PopupButtonBuilder = PopupButton Function(PopupButtonData data);
