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
class FloatingToolbar extends StatelessWidget {
  FloatingToolbar({
    Key? key,
    required this.selectNotifier,
    required this.items,
    this.alignment = ToolbarAlignment.bottomCenterHorizontal,
    this.backgroundColor,
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
    this.useToolbarBody = true,
    this.toolbarAnimationDuration = const Duration(milliseconds: 500),
    this.buttonChangeDuration = kThemeChangeDuration,
    this.buttonWaitDuration = const Duration(seconds: 2),
    this.buttonCurve = Curves.linear,
  }) : super(key: key) {
    _assignBasics();
    _assignWidgets();
  }

  /// Used by [FloatingToolbarItem.standard] to assign index if current value is
  /// null or set value to null if already selected. This ValueNotifier can be
  /// used to remotely trigger popups or to incorporate
  /// [FloatingToolbarItem.custom] into the standard behavior of FloatingToolbar.
  final ValueNotifier<int?> selectNotifier;

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

  /// Animation duration of changes to the toolbar surrounding the buttons.
  /// Applied to changes in alignment, margin, and content padding. Default is
  /// 500 milliseconds
  final Duration toolbarAnimationDuration;

  /// Wait duration applied to button hover triggered tooltips. Default is 2
  /// seconds
  final Duration buttonWaitDuration;

  /// Duration applied button state change animations. Applied to
  /// [FloatingToolbarItem.standard]. Default is [kThemeChangeDuration]
  final Duration buttonChangeDuration;

  /// Curve applied button state change animations. Applied to
  /// [FloatingToolbarItem.standard]. Default is [Curves.linear]
  final Curve buttonCurve;

  final bool useToolbarBody;

  // Filled in constructor body
  final List<Widget> _toolbarButtons = [];
  final List<Widget> _popupList = [];

  // Used to calculate button widths and toolbar width
  final List<String> _toolbarLabels = [];

  // Assigned in constructor body
  late final Alignment _toolbarAlignment;
  late final bool _isToolbarReverse;
  late final Axis _toolbarDirection;
  late final EdgeInsets _buttonSpacing;
  late final Axis _popupDirection;
  late final EdgeInsets _popupSpacing;
  late final Alignment _targetAnchor;
  late final Alignment _followerAnchor;
  late final Offset _followerOffset;

  void _assignBasics() {
    switch (alignment) {
      case ToolbarAlignment.topLeftVertical:
        _toolbarAlignment = Alignment.topLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: buttonSpacing);
        _popupSpacing = EdgeInsets.only(left: popupSpacing);
        _targetAnchor = Alignment.centerRight;
        _followerAnchor = Alignment.centerLeft;
        _followerOffset = Offset(contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.centerLeftVertical:
        _toolbarAlignment = Alignment.centerLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: buttonSpacing);
        _popupSpacing = EdgeInsets.only(left: popupSpacing);
        _targetAnchor = Alignment.centerRight;
        _followerAnchor = Alignment.centerLeft;
        _followerOffset = Offset(contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.bottomLeftVertical:
        _toolbarAlignment = Alignment.bottomLeft;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: buttonSpacing);
        _popupSpacing = EdgeInsets.only(left: popupSpacing);
        _targetAnchor = Alignment.centerRight;
        _followerAnchor = Alignment.centerLeft;
        _followerOffset = Offset(contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.topLeftHorizontal:
        _toolbarAlignment = Alignment.topLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: buttonSpacing);
        _popupSpacing = EdgeInsets.only(top: popupSpacing);
        _targetAnchor = Alignment.bottomCenter;
        _followerAnchor = Alignment.topCenter;
        _followerOffset = Offset(0.0, contentPadding.bottom);
        break;
      case ToolbarAlignment.topCenterHorizontal:
        _toolbarAlignment = Alignment.topCenter;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: buttonSpacing);
        _popupSpacing = EdgeInsets.only(top: popupSpacing);
        _targetAnchor = Alignment.bottomCenter;
        _followerAnchor = Alignment.topCenter;
        _followerOffset = Offset(0.0, contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightHorizontal:
        _toolbarAlignment = Alignment.topRight;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: buttonSpacing);
        _popupSpacing = EdgeInsets.only(top: popupSpacing);
        _targetAnchor = Alignment.bottomCenter;
        _followerAnchor = Alignment.topCenter;
        _followerOffset = Offset(0.0, contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightVertical:
        _toolbarAlignment = Alignment.topRight;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: buttonSpacing);
        _popupSpacing = EdgeInsets.only(right: popupSpacing);
        _targetAnchor = Alignment.centerLeft;
        _followerAnchor = Alignment.centerRight;
        _followerOffset = Offset(-contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.centerRightVertical:
        _toolbarAlignment = Alignment.centerRight;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: buttonSpacing);
        _popupSpacing = EdgeInsets.only(right: popupSpacing);
        _targetAnchor = Alignment.centerLeft;
        _followerAnchor = Alignment.centerRight;
        _followerOffset = Offset(-contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomRightVertical:
        _toolbarAlignment = Alignment.bottomRight;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: buttonSpacing);
        _popupSpacing = EdgeInsets.only(right: popupSpacing);
        _targetAnchor = Alignment.centerLeft;
        _followerAnchor = Alignment.centerRight;
        _followerOffset = Offset(-contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomLeftHorizontal:
        _toolbarAlignment = Alignment.bottomLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: buttonSpacing);
        _popupSpacing = EdgeInsets.only(bottom: popupSpacing);
        _targetAnchor = Alignment.topCenter;
        _followerAnchor = Alignment.bottomCenter;
        _followerOffset = Offset(0.0, -contentPadding.top);
        break;
      case ToolbarAlignment.bottomCenterHorizontal:
        _toolbarAlignment = Alignment.bottomCenter;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: buttonSpacing);
        _popupSpacing = EdgeInsets.only(bottom: popupSpacing);
        _targetAnchor = Alignment.topCenter;
        _followerAnchor = Alignment.bottomCenter;
        _followerOffset = Offset(0.0, -contentPadding.top);
        break;
      case ToolbarAlignment.bottomRightHorizontal:
        _toolbarAlignment = Alignment.bottomRight;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: buttonSpacing);
        _popupSpacing = EdgeInsets.only(bottom: popupSpacing);
        _targetAnchor = Alignment.topCenter;
        _followerAnchor = Alignment.bottomCenter;
        _followerOffset = Offset(0.0, -contentPadding.top);
        break;
    }
  }

  void _onTap(int index) {
    selectNotifier.value = selectNotifier.value == index ? null : index;
    if (onValueChanged != null) {
      onValueChanged!(index);
    }
  }

  bool _isAtStart(int index, int lastIndex) {
    return _isToolbarReverse ? index == lastIndex : index == 0;
  }

  Widget _custom(bool pad, FloatingToolbarItem item) {
    return pad
        ? item.customButton
        : Padding(
            padding: _buttonSpacing,
            child: item.customButton,
          );
  }

  Widget _button(int index, FloatingToolbarItem item) {
    return ValueListenableBuilder<int?>(
      valueListenable: selectNotifier,
      builder: (context, value, _) {
        return BaseIconicButton(
          state: index == value ? ButtonState.selected : ButtonState.unselected,
          iconData: item.toolbarItem.iconData,
          onPressed: () => _onTap(index),
          label: item.toolbarItem.label,
          tooltip: item.toolbarItem.tooltip,
          style: toolbarStyle,
          tooltipOffset: tooltipOffset,
          preferTooltipBelow: preferTooltipBelow,
          changeDuration: buttonChangeDuration,
          waitDuration: buttonWaitDuration,
          curve: buttonCurve,
        );
      },
    );
  }

  Widget _standard(
    bool pad,
    int index,
    FloatingToolbarItem item,
    LayerLink link,
  ) {
    return pad
        ? CompositedTransformTarget(
            link: link,
            child: _button(index, item),
          )
        : Padding(
            padding: _buttonSpacing,
            child: CompositedTransformTarget(
              link: link,
              child: _button(index, item),
            ),
          );
  }

  Widget _popup(int index, FloatingToolbarItem item, LayerLink link) {
    return Popup(
      index: index,
      listenable: selectNotifier,
      itemBuilderList: item.popups,
      spacing: _popupSpacing,
      followerData: FollowerData(
        link: link,
        direction: _popupDirection,
        targetAnchor: _targetAnchor,
        followerAnchor: _followerAnchor,
        offset: _followerOffset,
      ),
    );
  }

  void _assignWidgets() {
    bool onlyOneButton = items.length == 1;
    int lastIndex = items.length - 1;
    for (int index = 0; index < items.length; index++) {
      FloatingToolbarItem item = items[index];
      bool pad = onlyOneButton || _isAtStart(index, lastIndex);
      final LayerLink link = LayerLink();
      if (item.isCustom) {
        _toolbarButtons.add(_custom(pad, item));
        _toolbarLabels.add(item._customButton!.label ?? '');
      } else {
        _toolbarButtons.add(_standard(pad, index, item, link));
        _toolbarLabels.add(item._toolbarItem!.label ?? '');
        _popupList.add(_popup(index, item, link));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = toolbarStyle?.textStyle?.resolve({}) ??
        Theme.of(context).textTheme.bodyText2;
    double width = _toolbarDirection == Axis.horizontal
        ? iconicRowWidth(
            _toolbarLabels,
            textStyle,
            MediaQuery.of(context).textScaleFactor,
            toolbarStyle?.padding?.resolve({}) as EdgeInsets?,
          )
        : longestLabelIntrinsicWidth(
            _toolbarLabels,
            textStyle,
            MediaQuery.of(context).textScaleFactor,
          );
    return Stack(
      children: <Widget>[
            AnimatedAlign(
              duration: toolbarAnimationDuration,
              alignment: _toolbarAlignment,
              child: SingleChildScrollView(
                scrollDirection: _toolbarDirection,
                reverse: _isToolbarReverse,
                clipBehavior: Clip.none,
                child: AnimatedPadding(
                  duration: toolbarAnimationDuration,
                  padding: margin,
                  child: useToolbarBody
                      ? IntrinsicHeight(
                          child: Material(
                            shape: shape,
                            color: backgroundColor,
                            clipBehavior: clip,
                            elevation: elevation,
                            animationDuration: toolbarAnimationDuration,
                            child: AnimatedPadding(
                              duration: toolbarAnimationDuration,
                              padding: contentPadding,
                              child: SizedBox(
                                width: width,
                                child: Flex(
                                  direction: _toolbarDirection,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: _toolbarButtons
                                      .map((e) => Expanded(child: e))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: width,
                          child: Flex(
                            direction: _toolbarDirection,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: _toolbarButtons
                                .map((e) => Expanded(child: e))
                                .toList(),
                          ),
                        ),
                ),
              ),
            ),
          ] +
          _popupList,
    );
  }
}

enum _ToolbarShowing { first, second }

class ToolbarSwitch extends StatelessWidget {
  final ValueListenable<_ToolbarShowing> listenable;
  final Widget? first;
  final Widget? second;
  final Duration duration;

  ToolbarSwitch({
    Key? key,
    required this.listenable,
    required this.first,
    required this.second,
    this.duration = kThemeAnimationDuration,
  })  : assert(
            first == null || first.key != null, 'First widget must have a key'),
        assert(second == null || second.key != null,
            'First widget must have a key'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_ToolbarShowing>(
      valueListenable: listenable,
      builder: (context, value, _) {
        return AnimatedSwitcher(
          duration: duration,
          child: _show(value),
        );
      },
    );
  }

  Widget _show(_ToolbarShowing showing) {
    switch (showing) {
      case _ToolbarShowing.first:
        return first ?? SizedBox.shrink();
      case _ToolbarShowing.second:
        return second ?? SizedBox.shrink();
    }
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
      value: widget.listenable.value == widget.index ? 1.0 : 0.0,
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
