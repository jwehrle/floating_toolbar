library floating_toolbar;

import 'package:floating_toolbar/src/popup.dart';
import 'package:iconic_button/button.dart';
import 'package:flutter/material.dart';

import 'items.dart';

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

  final double modalMargin;

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
  /// [FloatingToolbarItem.popup]. Default is [kThemeChangeDuration]
  final Duration buttonChangeDuration;

  /// Curve applied button state change animations. Applied to
  /// [FloatingToolbarItem.popup]. Default is [Curves.linear]
  final Curve buttonCurve;

  /// Wrap toolbar in a Material
  final bool useToolbarBody;

  /// Make each non-custom button have the same width as the button with the longest
  /// label.
  final bool equalizeButton;

  final bool modalBarrier;

  FloatingToolbar({
    Key? key,
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
    this.modalMargin = 12.0,
    this.clip = Clip.antiAlias,
    this.elevation = 2.0,
    this.onValueChanged,
    this.tooltipOffset,
    this.preferTooltipBelow,
    this.toolbarStyle,
    this.useToolbarBody = true,
    this.equalizeButton = true,
    this.toolbarAnimationDuration = const Duration(milliseconds: 500),
    this.buttonChangeDuration = kThemeChangeDuration,
    this.buttonWaitDuration = const Duration(seconds: 2),
    this.buttonCurve = Curves.linear,
    this.modalBarrier = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FloatingToolbarState();
}

class FloatingToolbarState extends State<FloatingToolbar> {
  /// Used by [FloatingToolbarItem.popup] to assign index if current value is
  /// null or set value to null if already selected. This ValueNotifier can be
  /// used to remotely trigger popups or to incorporate
  /// [FloatingToolbarItem.basic] into the standard behavior of FloatingToolbar.
  final ValueNotifier<int?> selectNotifier = ValueNotifier(null);

  final LayerLink _toolbarLink = LayerLink();

  bool _useModal = false;

  // keeps track of custom buttons and doesn't equalize their width
  final Set<int> _customIndices = {};

  // Filled in constructor body
  final List<Widget> _toolbarButtons = [];
  final List<Widget> _popupList = [];

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
  late final Alignment _modalAlignment;

  void _assignBasics() {
    switch (widget.alignment) {
      case ToolbarAlignment.topLeftVertical:
        _toolbarAlignment = Alignment.topLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(left: widget.popupSpacing);
        _targetAnchor = Alignment.centerRight;
        _followerAnchor = Alignment.centerLeft;
        _modalAlignment = Alignment.centerLeft;
        _followerOffset = Offset(widget.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.centerLeftVertical:
        _toolbarAlignment = Alignment.centerLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(left: widget.popupSpacing);
        _targetAnchor = Alignment.centerRight;
        _followerAnchor = Alignment.centerLeft;
        _modalAlignment = Alignment.centerLeft;
        _followerOffset = Offset(widget.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.bottomLeftVertical:
        _toolbarAlignment = Alignment.bottomLeft;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(left: widget.popupSpacing);
        _targetAnchor = Alignment.centerRight;
        _followerAnchor = Alignment.centerLeft;
        _modalAlignment = Alignment.centerLeft;
        _followerOffset = Offset(widget.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.topLeftHorizontal:
        _toolbarAlignment = Alignment.topLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(top: widget.popupSpacing);
        _targetAnchor = Alignment.bottomCenter;
        _followerAnchor = Alignment.topCenter;
        _modalAlignment = Alignment.topCenter;
        _followerOffset = Offset(0.0, widget.contentPadding.bottom);
        break;
      case ToolbarAlignment.topCenterHorizontal:
        _toolbarAlignment = Alignment.topCenter;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(top: widget.popupSpacing);
        _targetAnchor = Alignment.bottomCenter;
        _followerAnchor = Alignment.topCenter;
        _modalAlignment = Alignment.topCenter;
        _followerOffset = Offset(0.0, widget.contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightHorizontal:
        _toolbarAlignment = Alignment.topRight;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(top: widget.popupSpacing);
        _targetAnchor = Alignment.bottomCenter;
        _followerAnchor = Alignment.topCenter;
        _modalAlignment = Alignment.topCenter;
        _followerOffset = Offset(0.0, widget.contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightVertical:
        _toolbarAlignment = Alignment.topRight;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(right: widget.popupSpacing);
        _targetAnchor = Alignment.centerLeft;
        _followerAnchor = Alignment.centerRight;
        _modalAlignment = Alignment.centerRight;
        _followerOffset = Offset(-widget.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.centerRightVertical:
        _toolbarAlignment = Alignment.centerRight;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(right: widget.popupSpacing);
        _targetAnchor = Alignment.centerLeft;
        _followerAnchor = Alignment.centerRight;
        _modalAlignment = Alignment.centerRight;
        _followerOffset = Offset(-widget.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomRightVertical:
        _toolbarAlignment = Alignment.bottomRight;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.vertical;
        _popupDirection = Axis.horizontal;
        _buttonSpacing = EdgeInsets.only(top: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(right: widget.popupSpacing);
        _targetAnchor = Alignment.centerLeft;
        _followerAnchor = Alignment.centerRight;
        _modalAlignment = Alignment.centerRight;
        _followerOffset = Offset(-widget.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomLeftHorizontal:
        _toolbarAlignment = Alignment.bottomLeft;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(bottom: widget.popupSpacing);
        _targetAnchor = Alignment.topCenter;
        _followerAnchor = Alignment.bottomCenter;
        _modalAlignment = Alignment.bottomCenter;
        _followerOffset = Offset(0.0, -widget.contentPadding.top);
        break;
      case ToolbarAlignment.bottomCenterHorizontal:
        _toolbarAlignment = Alignment.bottomCenter;
        _isToolbarReverse = false;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(bottom: widget.popupSpacing);
        _targetAnchor = Alignment.topCenter;
        _followerAnchor = Alignment.bottomCenter;
        _modalAlignment = Alignment.bottomCenter;
        _followerOffset = Offset(0.0, -widget.contentPadding.top);
        break;
      case ToolbarAlignment.bottomRightHorizontal:
        _toolbarAlignment = Alignment.bottomRight;
        _isToolbarReverse = true;
        _toolbarDirection = Axis.horizontal;
        _popupDirection = Axis.vertical;
        _buttonSpacing = EdgeInsets.only(left: widget.buttonSpacing);
        _popupSpacing = EdgeInsets.only(bottom: widget.popupSpacing);
        _targetAnchor = Alignment.topCenter;
        _followerAnchor = Alignment.bottomCenter;
        _modalAlignment = Alignment.bottomCenter;
        _followerOffset = Offset(0.0, -widget.contentPadding.top);
        break;
    }
  }

  void _onTap(int index) {
    selectNotifier.value = selectNotifier.value == index ? null : index;
    if (widget.onValueChanged != null) {
      widget.onValueChanged!(index);
    }
  }

  bool _isAtStart(int index, int lastIndex) {
    return _isToolbarReverse ? index == lastIndex : index == 0;
  }

  Widget _basic(bool noPad, FloatingToolbarItem item) {
    return noPad
        ? item.basicButton
        : Padding(
            padding: _buttonSpacing,
            child: item.basicButton,
          );
  }

// custom doesn't have tap - just like basic doesn't
  Widget _custom(bool noPad, FloatingToolbarItem item) {
    return noPad
        ? item.custom
        : Padding(
            padding: _buttonSpacing,
            child: item.custom,
          );
  }

  Widget _button(int index, FloatingToolbarItem item) {
    return ValueListenableBuilder<int?>(
      valueListenable: selectNotifier,
      builder: (context, value, _) {
        return BaseIconicButton(
          state: index == value ? ButtonState.selected : ButtonState.unselected,
          iconData: item.popupButton.iconData,
          onPressed: () => _onTap(index),
          label: item.popupButton.label,
          tooltip: item.popupButton.tooltip,
          style: widget.toolbarStyle,
          tooltipOffset: widget.tooltipOffset,
          preferTooltipBelow: widget.preferTooltipBelow,
          changeDuration: widget.buttonChangeDuration,
          waitDuration: widget.buttonWaitDuration,
          curve: widget.buttonCurve,
        );
      },
    );
  }

  Widget _modalButton(
    bool noPad,
    int index,
    FloatingToolbarItem item,
  ) {
    return noPad
        ? _button(index, item)
        : Padding(
            padding: _buttonSpacing,
            child: _button(index, item),
          );
  }

  Widget _standard(
    bool noPad,
    int index,
    FloatingToolbarItem item,
    LayerLink link,
  ) {
    return noPad
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
      followerPopupData: FollowerPopupData(
        link: link,
        direction: _popupDirection,
        targetAnchor: _targetAnchor,
        followerAnchor: _followerAnchor,
        offset: _followerOffset,
      ),
    );
  }

  Widget _modal(int index, FloatingToolbarItem item, LayerLink link) {
    return ToolbarModal(
      index: index,
      listenable: selectNotifier,
      builder: item.modalBuilder,
      margin: widget.modalMargin,
      alignment: _modalAlignment,
      link: link,
    );
  }

  void _assignWidgets() {
    bool onlyOneButton = widget.items.length == 1;
    int lastIndex = widget.items.length - 1;
    for (int index = 0; index < widget.items.length; index++) {
      FloatingToolbarItem item = widget.items[index];
      bool noPad = onlyOneButton || _isAtStart(index, lastIndex);
      final LayerLink link = LayerLink();
      switch (item.type) {
        case FloatingToolbarItemType.basic:
          _toolbarButtons.add(_basic(noPad, item));
          break;
        case FloatingToolbarItemType.popup:
          _toolbarButtons.add(_standard(noPad, index, item, link));
          _popupList.add(_popup(index, item, link));
          break;
        case FloatingToolbarItemType.custom:
          _customIndices.add(index);
          _toolbarButtons.add(_custom(noPad, item));
          break;
        case FloatingToolbarItemType.modal:
          _toolbarButtons.add(_modalButton(noPad, index, item));
          _popupList.add(_modal(index, item, _toolbarLink));
          break;
      }
    }
  }

  List<Widget> get _expandedButtons {
    if (_customIndices.isEmpty) {
      return _toolbarButtons.map((e) => Expanded(child: e)).toList();
    }
    List<Widget> buttons = [];
    for (int index = 0; index < _toolbarButtons.length; index++) {
      if (_customIndices.contains(index)) {
        buttons.add(_toolbarButtons[index]);
      } else {
        buttons.add(Expanded(
          child: _toolbarButtons[index],
        ));
      }
    }
    return buttons;
  }

  void _barrierListener() {
    if (selectNotifier.value == null && _useModal) {
      setState(() => _useModal = false);
    }
    if (selectNotifier.value != null && !_useModal) {
      setState(() => _useModal = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _assignBasics();
    _assignWidgets();
    selectNotifier.addListener(_barrierListener);
  }

  @override
  Widget build(BuildContext context) {
    Widget toolbar;
    if (widget.equalizeButton) {
      if (_toolbarDirection == Axis.horizontal) {
        toolbar = SizedBox(
          child: IntrinsicWidth(
            child: Flex(
              direction: _toolbarDirection,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: _expandedButtons,
            ),
          ),
        );
      } else {
        toolbar = SizedBox(
          child: IntrinsicHeight(
            child: Flex(
              direction: _toolbarDirection,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: _expandedButtons,
            ),
          ),
        );
      }
    } else {
      toolbar = Flex(
        direction: _toolbarDirection,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: _toolbarButtons,
      );
    }
    if (widget.useToolbarBody) {
      toolbar = Material(
        shape: widget.shape,
        color: widget.backgroundColor,
        clipBehavior: widget.clip,
        elevation: widget.elevation,
        animationDuration: widget.toolbarAnimationDuration,
        child: AnimatedPadding(
          duration: widget.toolbarAnimationDuration,
          padding: widget.contentPadding,
          child: toolbar,
        ),
      );
    }
    toolbar = CompositedTransformTarget(
      link: _toolbarLink,
      child: toolbar,
    );
    return Stack(
      children: <Widget>[
            if (widget.modalBarrier && _useModal)
              ModalBarrier(
                color: Colors.transparent,
                onDismiss: () => selectNotifier.value = null,
              ),
            AnimatedAlign(
              duration: widget.toolbarAnimationDuration,
              alignment: _toolbarAlignment,
              child: SingleChildScrollView(
                scrollDirection: _toolbarDirection,
                reverse: _isToolbarReverse,
                clipBehavior: Clip.none,
                child: AnimatedPadding(
                  duration: widget.toolbarAnimationDuration,
                  padding: widget.margin,
                  child: IntrinsicHeight(child: toolbar),
                ),
              ),
            ),
          ] +
          _popupList,
    );
  }

  @override
  void dispose() {
    selectNotifier.removeListener(_barrierListener);
    super.dispose();
  }
}
