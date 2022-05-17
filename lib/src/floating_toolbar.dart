library floating_toolbar;

import 'package:flutter/foundation.dart';
import 'package:iconic_button/button.dart';
import 'package:flutter/material.dart';

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

class FloatingToolbarItem {
  /// Used to make a toolbar button that controls associated popups. Selection
  /// of this button is handled by [FloatingToolbar]. Do not use this
  /// constructor if you want to control the appearance changes of this button.
  FloatingToolbarItem.standard(this._toolbarItem, this._popups)
      : this._customButton = null,
        this.isCustom = false;

  /// Used to insert a custom button into the [FloatingToolbar]. This button's
  /// selection is not controlled by [FloatingToolbar] and has no associated
  /// popups.
  FloatingToolbarItem.custom(this._customButton)
      : this.isCustom = true,
        this._toolbarItem = null,
        this._popups = null;

  /// IconicItem used in standard mode to build radio button style toolbar
  /// button
  final IconicItem? _toolbarItem;
  IconicItem get toolbarItem {
    assert(!isCustom);
    return _toolbarItem!;
  }

  /// List of PopupItemBuilders used to build a [Flex] of popup buttons
  /// associated with a radio button style toolbar button
  final List<PopupItemBuilder>? _popups;
  List<PopupItemBuilder> get popups {
    assert(!isCustom);
    return _popups!;
  }

  /// If true, [_customButton] is not null but both [_toolbarItem] and [_popups]
  /// are null. If false, both [_toolbarItem] and [_popups] are not null but
  /// [_customButton] is null.
  final bool isCustom;

  /// For use when no popups are to be associated with this toolbar button
  final IconicButton? _customButton;
  IconicButton get customButton {
    assert(isCustom);
    return _customButton!;
  }
}

/// Toolbar that aligns to any edge (left, top, right, bottom) with buttons that
/// displays popup buttons above, to the side of, or below the selected toolbar
/// button. FloatingToolbar is also Scrollable and minutely customizable in
/// terms of shapes, colors, highlights, etc.
///
/// The purpose of this Widget is to solve the UX problem of too many buttons
/// on a toolbar such that the user cannot be expected to either know what
/// the toolbar contains or that it scrolls or where the feature they're
/// looking for is. [FloatingToolbar] enables functional organization of buttons
/// that can be shown or hidden by user in an intuitive manner.
class FloatingToolbar extends StatefulWidget {
  const FloatingToolbar({
    Key? key,
    required this.items,
    this.alignment = ToolbarAlignment.bottomCenterHorizontal,
    this.backgroundColor,
    this.buttonSize = const Size(45.0, 40.0),
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
    this.onValueChanged,
    this.tooltipOffset,
    this.preferTooltipBelow,
    this.toolbarStyle,
  }) : super(key: key);

  /// The location of the toolbar. The first direction indicates alignment along
  /// a side, the second direction indicates alignment relative to that side.
  /// For example: leftTop means the toolbar will be placed vertically along the
  /// left side, and, the start of the toolbar will be at the top.
  final ToolbarAlignment alignment;

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

  /// Callback with itemKey of toolbar buttons pressed
  final ValueChanged<int?>? onValueChanged;

  /// Used to build the buttons of the toolbar
  final List<FloatingToolbarItem> items;

  /// Offset of tooltips
  final double? tooltipOffset;

  /// Whether to place tooltips below their button by default
  final bool? preferTooltipBelow;

  /// The background of the toolbar. Defaults to [Theme.primaryColor]
  final Color? backgroundColor;

  /// The ButtonStyle applied to IconicButtons of the toolbar.
  final ButtonStyle? toolbarStyle;

  @override
  State<StatefulWidget> createState() => FloatingToolbarState();
}

class FloatingToolbarState extends State<FloatingToolbar> {
  /// Stores currently selected item index or null if none is selected.
  final ValueNotifier<int?> _select = ValueNotifier(null);

  /// All widgets created in initState which are then displayed in a Stack:
  /// Toolbar and all popups
  final List<Widget> _children = [];

  void _onTap(int index) {
    _select.value = _select.value == index ? null : index;
    if (widget.onValueChanged != null) {
      widget.onValueChanged!(index);
    }
  }

  @override
  void initState() {
    super.initState();
    final Alignment toolbarAlignment;
    final bool isToolbarReverse;
    final Axis toolbarDirection;
    final Axis popupDirection;
    final EdgeInsets buttonSpacing;
    final EdgeInsets popupSpacing;
    final Alignment targetAnchor;
    final Alignment followerAnchor;
    final Offset followerOffset;
    switch (widget.alignment) {
      case ToolbarAlignment.topLeftVertical:
        toolbarAlignment = Alignment.topLeft;
        isToolbarReverse = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(left: widget.popupSpacing);
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
        followerOffset = Offset(widget.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.centerLeftVertical:
        toolbarAlignment = Alignment.centerLeft;
        isToolbarReverse = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(left: widget.popupSpacing);
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
        followerOffset = Offset(widget.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.bottomLeftVertical:
        toolbarAlignment = Alignment.bottomLeft;
        isToolbarReverse = true;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(left: widget.popupSpacing);
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
        followerOffset = Offset(widget.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.topLeftHorizontal:
        toolbarAlignment = Alignment.topLeft;
        isToolbarReverse = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(top: widget.popupSpacing);
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
        followerOffset = Offset(0.0, widget.contentPadding.bottom);
        break;
      case ToolbarAlignment.topCenterHorizontal:
        toolbarAlignment = Alignment.topCenter;
        isToolbarReverse = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(top: widget.popupSpacing);
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
        followerOffset = Offset(0.0, widget.contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightHorizontal:
        toolbarAlignment = Alignment.topRight;
        isToolbarReverse = true;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(top: widget.popupSpacing);
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
        followerOffset = Offset(0.0, widget.contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightVertical:
        toolbarAlignment = Alignment.topRight;
        isToolbarReverse = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(right: widget.popupSpacing);
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
        followerOffset = Offset(-widget.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.centerRightVertical:
        toolbarAlignment = Alignment.centerRight;
        isToolbarReverse = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(right: widget.popupSpacing);
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
        followerOffset = Offset(-widget.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomRightVertical:
        toolbarAlignment = Alignment.bottomRight;
        isToolbarReverse = true;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(right: widget.popupSpacing);
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
        followerOffset = Offset(-widget.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomLeftHorizontal:
        toolbarAlignment = Alignment.bottomLeft;
        isToolbarReverse = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(bottom: widget.popupSpacing);
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
        followerOffset = Offset(0.0, -widget.contentPadding.top);
        break;
      case ToolbarAlignment.bottomCenterHorizontal:
        toolbarAlignment = Alignment.bottomCenter;
        isToolbarReverse = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(bottom: widget.popupSpacing);
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
        followerOffset = Offset(0.0, -widget.contentPadding.top);
        break;
      case ToolbarAlignment.bottomRightHorizontal:
        toolbarAlignment = Alignment.bottomRight;
        isToolbarReverse = true;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(bottom: widget.popupSpacing);
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
        followerOffset = Offset(0.0, -widget.contentPadding.top);
        break;
    }
    final List<Widget> targets = [];
    final List<Widget> followers = [];
    for (int index = 0; index < widget.items.length; index++) {
      FloatingToolbarItem item = widget.items[index];
      final LayerLink link = LayerLink();
      if (item.isCustom) {
        targets.add(item.customButton);
      } else {
        targets.add(
          CompositedTransformTarget(
            link: link,
            child: ValueListenableBuilder<int?>(
              valueListenable: _select,
              builder: (context, value, _) {
                return BaseIconicButton(
                  state: index == value
                      ? ButtonState.selected
                      : ButtonState.unselected,
                  iconData: item.toolbarItem.iconData,
                  onPressed: () => _onTap(index),
                  label: item.toolbarItem.label,
                  tooltip: item.toolbarItem.tooltip,
                  style: widget.toolbarStyle,
                  tooltipOffset: widget.tooltipOffset,
                  preferTooltipBelow: widget.preferTooltipBelow,
                );
              },
            ),
          ),
        );
        followers.add(
          Popup(
            index: index,
            listenable: _select,
            itemBuilderList: item.popups,
            spacing: popupSpacing,
            followerData: FollowerData(
              link: link,
              direction: popupDirection,
              targetAnchor: targetAnchor,
              followerAnchor: followerAnchor,
              offset: followerOffset,
            ),
          ),
        );
      }
    }
    final List<Widget> toolbarButtons = [];
    if (targets.length == 1) {
      toolbarButtons.add(targets.first);
    } else if (targets.length > 1) {
      toolbarButtons.add(targets.first);
      for (int index = 1; index < targets.length; index++) {
        toolbarButtons.add(Padding(padding: buttonSpacing));
        toolbarButtons.add(targets[index]);
      }
    }
    _children.add(
      Align(
        alignment: toolbarAlignment,
        child: SingleChildScrollView(
          scrollDirection: toolbarDirection,
          reverse: isToolbarReverse,
          clipBehavior: Clip.none,
          child: Padding(
            padding: widget.margin,
            child: Material(
              shape: widget.shape,
              color: widget.backgroundColor,
              clipBehavior: widget.clip,
              elevation: widget.elevation,
              child: Padding(
                padding: widget.contentPadding,
                child: Flex(
                  direction: toolbarDirection,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: toolbarButtons,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    _children.addAll(followers);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _children,
    );
  }

  @override
  void dispose() {
    _select.dispose();
    super.dispose();
  }
}

/// Encapsulates parameters needed for CompositedTransformFollower on which
/// [Popup] is based.
class FollowerData {
  final LayerLink link;
  final Axis direction;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;

  FollowerData({
    required this.link,
    required this.direction,
    required this.targetAnchor,
    required this.followerAnchor,
    required this.offset,
  });
}

/// Used to build BaseIconicButton popup items. The builder format is required
/// so that ThemeData can be accessed in Widgets using this class from initState
/// Builds an IconicButton equivalent.
class PopupItemBuilder {
  final ButtonController controller;
  final BaseIconicButton Function(
    BuildContext context,
    ButtonState state,
    Widget? child,
  ) builder;

  PopupItemBuilder({required this.controller, required this.builder});
}

/// Shows or hides popup items which are built from a list of [itemBuilderList]
/// based on [listenable] value comparison to [index].
class Popup extends StatefulWidget {
  const Popup({
    Key? key,
    required this.index,
    required this.listenable,
    required this.itemBuilderList,
    required this.spacing,
    required this.followerData,
  }) : super(key: key);

  /// Which toolbar button this popup is associated with
  final int index;

  /// Event changes in the toolbar button selected determine whether these
  /// popup elements are shown or hidden
  final ValueListenable<int?> listenable;

  /// Builder for each popup element
  final List<PopupItemBuilder> itemBuilderList;

  /// Spacing between popup elements
  final EdgeInsets spacing;

  /// Parameters used for the CompositedTransformFollower on which this calls is
  /// based.
  final FollowerData followerData;

  @override
  State<StatefulWidget> createState() => PopupState();
}

class PopupState extends State<Popup> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final List<Widget> _children;

  void _onSelectListener() {
    if (widget.listenable.value == widget.index) {
      if (_scaleController.status == AnimationStatus.dismissed) {
        _scaleController.forward();
      }
    } else {
      if (_scaleController.status == AnimationStatus.completed) {
        _scaleController.reverse();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: kThemeAnimationDuration,
    );
    widget.listenable.addListener(_onSelectListener);
    _children = widget.itemBuilderList
        .map(
          (item) => Padding(
            padding: widget.spacing,
            child: ScaleTransition(
              scale: _scaleController.view,
              child: ValueListenableBuilder<ButtonState>(
                valueListenable: item.controller,
                builder: item.builder,
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      top: 0.0,
      child: CompositedTransformFollower(
        link: widget.followerData.link,
        targetAnchor: widget.followerData.targetAnchor,
        followerAnchor: widget.followerData.followerAnchor,
        offset: widget.followerData.offset,
        child: Flex(
          direction: widget.followerData.direction,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _children,
        ),
      ),
    );
  }
}
