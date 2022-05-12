library floating_toolbar;

import 'package:iconic_button/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

class IconicItem {
  final IconData iconData;
  final VoidCallback onPressed;
  final String? label;
  final String? tooltip;

  IconicItem({
    required this.iconData,
    required this.onPressed,
    this.label,
    this.tooltip,
  });
}

class FloatingToolbarItem {
  final String itemKey;

  final IconicItem? _toolbarItem;
  IconicItem get toolbarItem {
    assert(!isCustom);
    return _toolbarItem!;
  }

  final List<IconicButton>? _popups;
  List<IconicButton> get popups {
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

  /// Used to make a toolbar button that controls associated popups. Selection
  /// of this button is handled by [FloatingToolbar]. Do not use this
  /// constructor if you want to control the appearance changes of this button.
  FloatingToolbarItem.standard(this.itemKey, this._toolbarItem, this._popups)
      : this._customButton = null,
        this.isCustom = false;

  /// Used to insert a custom button into the [FloatingToolbar]. This button's
  /// selection is not controlled by [FloatingToolbar] and has no associated
  /// popups.
  FloatingToolbarItem.custom(this.itemKey, this._customButton)
      : this.isCustom = true,
        this._toolbarItem = null,
        this._popups = null;
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
  FloatingToolbar({
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
  final ValueChanged<String?>? onValueChanged;

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
  /// Stores currently selected itemKey or null if none is selected.
  final ValueNotifier<String?> _selectionNotifier = ValueNotifier(null);

  final List<Widget> _toolbarButtons = [];
  final Map<String, GlobalKey<IconicButtonState>> _toolMap = {};
  final Map<String, GlobalKey<PopupState>> _popMap = {};
  // final List<OverlayEntry> _entries = [];
  bool _entriesInserted = false;
  late final Alignment _toolbarAlignment;
  late final bool _isToolbarReverse;
  late final Axis _toolbarDirection;

  void _selectionListener() {
    final String? itemKey = _selectionNotifier.value;
    _toolMap.forEach((key, value) {
      final tool = _toolMap[key]?.currentState;
      if (tool != null) {
        if (key == itemKey) {
          tool.select();
        } else {
          tool.unSelect();
        }
      }
    });
    _popMap.forEach((key, popup) {
      final pop = _popMap[key]?.currentState;
      if (pop != null) {
        if (key == itemKey) {
          pop.select();
        } else if (pop.status != AnimationStatus.dismissed) {
          pop.unSelect();
        }
      }
    });
  }

  IconicButton _toolbarButtonFromItem(FloatingToolbarItem item) {
    return IconicButton(
      key: _toolMap[item.itemKey],
      iconData: item.toolbarItem.iconData,
      onPressed: () {
        _selectionNotifier.value =
            _selectionNotifier.value == item.itemKey ? null : item.itemKey;
        item.toolbarItem.onPressed();
        if (widget.onValueChanged != null) {
          widget.onValueChanged!(item.itemKey);
        }
      },
      label: item.toolbarItem.label,
      tooltip: item.toolbarItem.tooltip,
      style: widget.toolbarStyle,
      tooltipOffset: widget.tooltipOffset,
      preferTooltipBelow: widget.preferTooltipBelow,
    );
  }

  /// Wraps [FloatingToolbarItem] of parent in [CompositedTransformTarget] and
  /// [CompositedTransformFollower] and [IconicButton]. Saves [GlobalKey] of
  /// each toolbar button in [_toolMap] and a [GlobalKey] for each [Popup] in
  /// [_popMap]. Returns the list of [CompositedTransformTarget].
  List<Widget> _makeComposited({
    required Axis direction,
    required EdgeInsets spacing,
    required Alignment targetAnchor,
    required Alignment followerAnchor,
    required Offset followerOffset,
    required List<OverlayEntry> entries,
  }) {
    final List<Widget> targets = [];
    widget.items.forEach((item) {
      _toolMap[item.itemKey] = GlobalKey<IconicButtonState>();
      final LayerLink link = LayerLink();
      if (item.isCustom) {
        targets.add(item.customButton);
      } else {
        targets.add(
          CompositedTransformTarget(
            link: link,
            child: _toolbarButtonFromItem(item),
          ),
        );
        final popupKey = GlobalKey<PopupState>();
        _popMap[item.itemKey] = popupKey;
        entries.add(
          OverlayEntry(
            builder: (context) => Popup(
              key: popupKey,
              itemKey: item.itemKey,
              link: link,
              direction: direction,
              spacing: spacing,
              targetAnchor: targetAnchor,
              followerAnchor: followerAnchor,
              offset: followerOffset,
              buttons: item.popups,
            ),
          ),
        );
      }
    });
    return targets;
  }

  void _assignToolbarButtons({
    required List<Widget> targets,
    required EdgeInsetsGeometry spacing,
  }) {
    if (targets.length == 1) {
      _toolbarButtons.add(targets.first);
    } else {
      _toolbarButtons.add(targets.first);
      for (int index = 1; index < targets.length; index++) {
        _toolbarButtons.add(Padding(padding: spacing));
        _toolbarButtons.add(targets[index]);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final Axis popupDirection;
    final EdgeInsets buttonSpacing;
    final EdgeInsets popupSpacing;
    final Alignment targetAnchor;
    final Alignment followerAnchor;
    final Offset followerOffset;
    switch (widget.alignment) {
      case ToolbarAlignment.topLeftVertical:
        _toolbarAlignment = Alignment.topLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(left: widget.popupSpacing);
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
        followerOffset = Offset(widget.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.centerLeftVertical:
        _toolbarAlignment = Alignment.centerLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(left: widget.popupSpacing);
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
        followerOffset = Offset(widget.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.bottomLeftVertical:
        _toolbarAlignment = Alignment.bottomLeft;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(left: widget.popupSpacing);
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
        followerOffset = Offset(widget.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.topLeftHorizontal:
        _toolbarAlignment = Alignment.topLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(top: widget.popupSpacing);
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
        followerOffset = Offset(0.0, widget.contentPadding.bottom);
        break;
      case ToolbarAlignment.topCenterHorizontal:
        _toolbarAlignment = Alignment.topCenter;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(top: widget.popupSpacing);
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
        followerOffset = Offset(0.0, widget.contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightHorizontal:
        _toolbarAlignment = Alignment.topRight;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(top: widget.popupSpacing);
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
        followerOffset = Offset(0.0, widget.contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightVertical:
        _toolbarAlignment = Alignment.topRight;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(right: widget.popupSpacing);
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
        followerOffset = Offset(-widget.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.centerRightVertical:
        _toolbarAlignment = Alignment.centerRight;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(right: widget.popupSpacing);
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
        followerOffset = Offset(-widget.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomRightVertical:
        _toolbarAlignment = Alignment.bottomRight;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(right: widget.popupSpacing);
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
        followerOffset = Offset(-widget.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomLeftHorizontal:
        _toolbarAlignment = Alignment.bottomLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(bottom: widget.popupSpacing);
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
        followerOffset = Offset(0.0, -widget.contentPadding.top);
        break;
      case ToolbarAlignment.bottomCenterHorizontal:
        _toolbarAlignment = Alignment.bottomCenter;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(bottom: widget.popupSpacing);
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
        followerOffset = Offset(0.0, -widget.contentPadding.top);
        break;
      case ToolbarAlignment.bottomRightHorizontal:
        _toolbarAlignment = Alignment.bottomRight;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        popupSpacing = EdgeInsets.only(bottom: widget.popupSpacing);
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
        followerOffset = Offset(0.0, -widget.contentPadding.top);
        break;
    }
    if (!_entriesInserted) {
      final List<OverlayEntry> entries = [];
      final List<Widget> targets = _makeComposited(
        direction: popupDirection,
        spacing: popupSpacing,
        targetAnchor: targetAnchor,
        followerAnchor: followerAnchor,
        followerOffset: followerOffset,
        entries: entries,
      );
      _assignToolbarButtons(targets: targets, spacing: buttonSpacing);
      _selectionNotifier.addListener(_selectionListener);
      WidgetsBinding.instance
          ?.addPostFrameCallback((_) => _insertPopups(entries));
    }
  }

  void _insertPopups(entries) {
    if (!_entriesInserted) {
      Overlay.of(context)?.insertAll(entries);
      _entriesInserted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _toolbarAlignment,
      child: SingleChildScrollView(
        scrollDirection: _toolbarDirection,
        reverse: _isToolbarReverse,
        clipBehavior: Clip.none,
        child: Padding(
          padding: widget.margin,
          child: Material(
            shape: widget.shape,
            color: widget.backgroundColor ?? Theme.of(context).primaryColor,
            clipBehavior: widget.clip,
            elevation: widget.elevation,
            child: Padding(
              padding: widget.contentPadding,
              child: Flex(
                direction: _toolbarDirection,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: _toolbarButtons,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _selectionNotifier.dispose();
    // _entries.forEach((entry) => entry.remove());
    super.dispose();
  }
}

class Popup extends StatefulWidget {
  final List<IconicButton> buttons;
  final String itemKey;
  final LayerLink link;
  final EdgeInsets spacing;
  final Axis direction;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;

  const Popup({
    Key? key,
    required this.buttons,
    required this.itemKey,
    required this.link,
    required this.spacing,
    required this.direction,
    required this.targetAnchor,
    required this.followerAnchor,
    required this.offset,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PopupState();
}

class PopupState extends State<Popup> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  void select() => _controller.forward(from: 0.0);

  void unSelect() => _controller.reverse(from: 1.0);

  AnimationStatus get status => _controller.status;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: kThemeAnimationDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      top: 0.0,
      child: CompositedTransformFollower(
        link: widget.link,
        targetAnchor: widget.targetAnchor,
        followerAnchor: widget.followerAnchor,
        offset: widget.offset,
        child: Flex(
          direction: widget.direction,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.buttons
              .map((button) => Padding(
                    padding: widget.spacing,
                    child: ScaleTransition(
                      scale: _controller.view,
                      child: button,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
