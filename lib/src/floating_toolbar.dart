// ignore_for_file: public_member_api_docs
library floating_toolbar;

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconic_button/iconic_button.dart';

import 'package:floating_toolbar/src/popup.dart';

import 'items.dart';

/// Single enum combining Alignment and Axis.
/// (Useful for switch case)
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

/// Builder for toolbar buttons whose selection is managed by [FloatingToolbar]
typedef ItemBuilder = Widget Function(int index, FloatingToolbarItem item);

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
  /// Creates a toolbar that aligns to any edge (left, top, right, bottom) with
  /// buttons that displays popup buttons above, to the side of, or below the
  /// selected toolbar button. FloatingToolbar is also Scrollable and minutely
  /// customizable in terms of shapes, colors, highlights, etc.
  ///
  /// The purpose of this Widget is to solve the UX problem of too many buttons
  /// on a toolbar such that the user cannot be expected to either know what
  /// the toolbar contains or that it scrolls or where the feature they're
  /// looking for is. [FloatingToolbar] enables functional organization of buttons
  /// that can be shown or hidden by user in an intuitive manner.
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
    this.useToolbarBody = true,
    this.equalizeButton = true,
    this.toolbarAnimationDuration = const Duration(milliseconds: 500),
    this.buttonChangeDuration = kThemeChangeDuration,
    this.buttonWaitDuration = const Duration(seconds: 2),
    this.buttonCurve = Curves.linear,
    this.modalBarrier = true,
    this.showAlertDot = false,
    this.alertDotColor = Colors.red,
    this.toolbarButtonStyle,
    this.primary,
    this.onPrimary,
    this.onSurface,
    this.shadowColor,
    this.buttonElevation = 0.0,
    this.textStyle,
    this.padding,
    this.buttonShape = kDefaultRectangularShape,
    this.splashFactory,
    this.itemSelector,
    this.barrierColor,
    this.blur,
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

  /// Whether to show an alert dot (usually indicative of a notification) on
  /// top of this button. Defaults to false
  final bool showAlertDot;

  /// The color of the optional alert dot. Defaults to [Colors.red]
  final Color alertDotColor;

  /// Optional style for toolbar buttons (not popup buttons)
  /// If provided, the non-null fields of this style are preferred over
  /// inherited IconicButtonTheme and any other style-related parameters 
  /// provided in this constructor.
  /// Practically speaking, if you provide [toolbarButtonStyle] don't 
  /// bother providing [primary], [onPrimary], [onSurface], 
  /// [shadowColor], [elevation], [shape], [textStyle], [padding], 
  /// [buttonChangeDuration], or [splashFactory]
  final ButtonStyle? toolbarButtonStyle;

  /// The foreground color when selected and background color when unselected.
  final Color? primary;

  /// The background color when selected and foreground color when unselected.
  final Color? onPrimary;

  /// The foreground color when disabled.
  final Color? onSurface;

  /// Color of the shadow when elevation is > 0.0
  final Color? shadowColor;

  /// The elevation of the button, defaults to 0.0
  final double? buttonElevation;

  /// The TextStyle of the label, defaults to TextStyle()
  final TextStyle? textStyle;

  /// Padding around the foreground contents of the button. Defaults to
  /// ThemeData.buttonTheme.padding
  final EdgeInsetsGeometry? padding;

  /// The shape of the button, by default a RoundedRectangle with radius of 4.0
  final OutlinedBorder? buttonShape;

  /// The splash factory, defaults to InkRipple.splashFactory
  final InteractiveInkFeatureFactory? splashFactory;

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

  /// Whether to insert a modal barrier behind the toolbar when a selection is made.
  /// Modal barrier is removed when anything but the toolbar or popups are tapped
  /// or panned.
  final bool modalBarrier;

  /// Optional [ItemSelector] for injecting toolbar item selections.
  final ItemSelector? itemSelector;

  /// Optional modal barrier color used only if [modalBarrier] is true.
  final Color? barrierColor;

  /// Optional background blur effect used only if [modalBarrier] is true.
  final ImageFilter? blur;

  @override
  State<StatefulWidget> createState() => FloatingToolbarState();
}

class FloatingToolbarState extends State<FloatingToolbar> {
  /// Used by [FloatingToolbarItem.popup] to assign index if current value is
  /// null or set value to null if already selected. This ValueNotifier can be
  /// used to remotely trigger popups or to incorporate
  /// [FloatingToolbarItem.basic] into the standard behavior of FloatingToolbar.
  final ValueNotifier<int?> _selectNotifier = ValueNotifier(null);

  /// The set of all button indices whose selection is managed by this widget.
  final Set<int> _selectableItems = {};

  /// False by default.
  bool _useBarrier = false;

  /// Assigns selection value and calls onValueChanged if not null
  void _onTap(int index) {
    _selectNotifier.value = _selectNotifier.value == index ? null : index;
    if (widget.onValueChanged != null) {
      widget.onValueChanged!(index);
    }
  }

  /// [ItemBuilder] for buttons whose selection is managed by this widget.
  /// Used by [_ToolbarBundle]
  Widget _buttonBuilder(int index, FloatingToolbarItem item) {
    _selectableItems.add(index);
    return ValueListenableBuilder<int?>(
      valueListenable: _selectNotifier,
      builder: (context, value, _) {
        return BaseIconicButton(
          isSelected: index == value,
          isEnabled: true,
          iconData: item.popupItem.iconData,
          onPressed: () => _onTap(index),
          label: item.popupItem.label,
          tooltip: item.popupItem.tooltip,
          showAlertDot: widget.showAlertDot,
          alertDotColor: widget.alertDotColor,
          style: widget.toolbarButtonStyle,
          primary: widget.primary,
          onPrimary: widget.onPrimary,
          onSurface: widget.onSurface,
          shadowColor: widget.shadowColor,
          elevation: widget.buttonElevation,
          textStyle: widget.textStyle,
          padding: widget.padding,
          shape: widget.buttonShape,
          splashFactory: widget.splashFactory,
          tooltipOffset: widget.tooltipOffset,
          preferTooltipBelow: widget.preferTooltipBelow,
          animationDuration: widget.buttonChangeDuration,
          waitDuration: widget.buttonWaitDuration,
          curve: widget.buttonCurve,
        );
      },
    );
  }

  /// Sets [_useBarrier] based on [_selectNotifier] and previous  value of [_useBarrier]
  /// If no item is selected and barrier is on, turn barrier off.
  /// If some item is selected and barrier is not on, turn it on.
  void _barrierListener() {
    if (_selectNotifier.value == null && _useBarrier) {
      setState(() => _useBarrier = false);
    }
    if (_selectNotifier.value != null && !_useBarrier) {
      setState(() => _useBarrier = true);
    }
  }

  /// Determines whether [value] is suitable to be assigned to [_selectNotifier]
  bool _isValidSelection(int? value) =>
      value == null || _selectableItems.contains(value);

  /// Assigns [_selectNotifier] based on [widget.itemSelector].
  void _selectorListener() {
    if (!mounted) {
      return;
    }
    if (widget.itemSelector == null) {
      return;
    }
    if (!_isValidSelection(widget.itemSelector!.selected)) {
      return;
    }
    _selectNotifier.value = widget.itemSelector!.selected;
  }

  /// Callback for modal barrier dismissing. Used by [FloatingToolbarBarrier]
  void _barrierDismiss() => _selectNotifier.value = null;

  @override
  void initState() {
    super.initState();
    if (widget.modalBarrier) {
      _selectNotifier.addListener(_barrierListener);
    }
    widget.itemSelector?.addListener(_selectorListener);
  }

  @override
  Widget build(BuildContext context) {
    final toolbarBundle = _ToolbarBundle(
      toolbarAlignment: widget.alignment,
      buttonSpacing: widget.buttonSpacing,
      popupSpacing: widget.popupSpacing,
      contentPadding: widget.contentPadding,
      selectionListenable: _selectNotifier,
      buttonBuilder: _buttonBuilder,
      items: widget.items,
    );
    Widget toolbar = _ToolbarFlex(
      buttons: toolbarBundle.toolbarButtons,
      custom: toolbarBundle.customIndices,
      equalize: widget.equalizeButton,
      direction: toolbarBundle.toolbarDirection,
    );
    if (widget.useToolbarBody) {
      toolbar = _ToolbarMaterial(
        shape: widget.shape,
        color: widget.backgroundColor,
        clip: widget.clip,
        elevation: widget.elevation,
        animationDuration: widget.toolbarAnimationDuration,
        contentPadding: widget.contentPadding,
        toolbar: toolbar,
      );
    }
    toolbar = _ToolbarDecoration(
      duration: widget.toolbarAnimationDuration,
      alignment: toolbarBundle.alignment,
      direction: toolbarBundle.toolbarDirection,
      isReversed: toolbarBundle.isReversed,
      margin: widget.margin,
      toolbar: toolbar,
    );
    return _ToolbarStack(
      toolbar: toolbar,
      popups: toolbarBundle.popupList,
      animationDuration: widget.toolbarAnimationDuration,
      onBarrierDismiss: _useBarrier ? _barrierDismiss : null,
      barrierColor: widget.barrierColor,
      blur: widget.blur,
    );
  }

  @override
  void dispose() {
    _selectNotifier.removeListener(_barrierListener);
    widget.itemSelector?.removeListener(_selectorListener);
    super.dispose();
  }
}

/// The Flex of toolbar buttons that forms the always-visible part of
/// every [FloatingToolbar]
class _ToolbarFlex extends StatelessWidget {
  /// Creates the Flex of toolbar buttons that forms the always-visible part of
  /// every [FloatingToolbar].
  _ToolbarFlex({
    required this.custom,
    required this.buttons,
    required this.equalize,
    required this.direction,
  });

  /// The indices of toolbar widgets whose selection is not managed by [FloatingToolbar]
  final Set<int> custom;

  /// All buttons in this toolbar regardless of type
  final List<Widget> buttons;

  /// Whether to give all non-customized buttons the same size in the axis of [direction]
  final bool equalize;

  /// The [Axis] of this toolbar
  final Axis direction;

  /// Wraps non-custom buttons in [Expanded]
  List<Widget> _expandButtons(Set<int> cstmInd, List<Widget> btnList) {
    if (cstmInd.isEmpty) {
      return btnList.map((e) => Expanded(child: e)).toList();
    }
    List<Widget> buttons = [];
    for (int index = 0; index < btnList.length; index++) {
      if (cstmInd.contains(index)) {
        buttons.add(btnList[index]);
      } else {
        buttons.add(Expanded(
          child: btnList[index],
        ));
      }
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    if (equalize) {
      final children = _expandButtons(custom, buttons);
      if (direction == Axis.horizontal) {
        return SizedBox(
          child: IntrinsicWidth(
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: children,
            ),
          ),
        );
      } else {
        return SizedBox(
          child: IntrinsicHeight(
            child: Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: children,
            ),
          ),
        );
      }
    }
    return Flex(
      direction: direction,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }
}

/// Wraps toolbar in [Material]. Used when [FloatingToolbar.useToolbarBody] is true.
class _ToolbarMaterial extends StatelessWidget {
  /// Creates [Material] with [toolbar] as child.
  _ToolbarMaterial({
    required this.shape,
    required this.color,
    required this.clip,
    required this.elevation,
    required this.animationDuration,
    required this.contentPadding,
    required this.toolbar,
  });

  /// [ShapeBorder] applied to [Material]
  final ShapeBorder shape;

  /// Optional [Color] applied to [Material]
  final Color? color;

  /// [Clip] applied to [Material]
  final Clip clip;

  /// elevation applied to [Material]
  final double elevation;

  /// [Duration] applied to [Material] and [AnimatedPadding]
  final Duration animationDuration;

  /// [EdgeInsets] applied to [AnimatedPadding]
  final EdgeInsets contentPadding;

  /// The toolbar to wrapped.
  final Widget toolbar;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: shape,
      color: color,
      clipBehavior: clip,
      elevation: elevation,
      animationDuration: animationDuration,
      child: AnimatedPadding(
        duration: animationDuration,
        padding: contentPadding,
        child: toolbar,
      ),
    );
  }
}

/// Wraps [toolbar] in embedding widgets that set alignment, scrolling, directions,
///  anchor, clip, padding, and height.
class _ToolbarDecoration extends StatelessWidget {
  /// Creates widget that wraps [toolbar] in embedding widgets that set alignment,
  /// scrolling, directions, anchor, clip, padding, and height.
  const _ToolbarDecoration({
    required this.duration,
    required this.alignment,
    required this.direction,
    required this.isReversed,
    required this.margin,
    required this.toolbar,
  });

  /// [Duration] of animated changes in alignment and padding.
  final Duration duration;

  /// [Alignment] of toolbar
  final Alignment alignment;

  /// [Axis] of scrolling
  final Axis direction;

  /// Whether to anchor the first (false) or last (true) toolbar item
  final bool isReversed;

  /// The [EdgeInsets] wrapped around toolbar setting the space
  /// between the toolbar and everything else.
  final EdgeInsets margin;

  /// The toolbar to wrapped.
  final Widget toolbar;

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: duration,
      alignment: alignment,
      child: SingleChildScrollView(
        scrollDirection: direction,
        reverse: isReversed,
        clipBehavior: Clip.none,
        child: AnimatedPadding(
          duration: duration,
          padding: margin,
          child: IntrinsicHeight(child: toolbar),
        ),
      ),
    );
  }
}

/// Wraps widgets comprising a [FloatingToolbar] in a stack. This is critical
/// for positioning popups relative to toolbar buttons.
class _ToolbarStack extends StatelessWidget {
  /// Creates a [Stack] which wraps widgets comprising a [FloatingToolbar].
  ///  This is critical for positioning popups relative to toolbar buttons.
  const _ToolbarStack({
    required this.toolbar,
    required this.popups,
    required this.animationDuration,
    this.onBarrierDismiss,
    this.barrierColor,
    this.blur,
  });

  /// The part of [FloatingToolbar] which is always visible
  final Widget toolbar;

  /// The popups associated with managed buttons which appear or
  /// disappear depending on selection status.
  final List<Widget> popups;

  /// Optional modal barrier callback used when a [FloatingToolbarBarrier] is
  /// desired during popup display. If not null, a barrier will be added.
  final VoidCallback? onBarrierDismiss;

  /// Optional color for [FloatingToolbarBarrier]
  final Color? barrierColor;

  /// Optional blur effect for [FloatingToolbarBarrier]
  final ImageFilter? blur;

  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      AnimatedSwitcher(
        duration: animationDuration,
        child: onBarrierDismiss != null
            ? FloatingToolbarBarrier(
                onDismiss: onBarrierDismiss!,
                color: barrierColor,
                blur: blur,
              )
            : SizedBox.expand(),
      ),
      toolbar,
    ];
    children.addAll(popups);
    return Stack(
      children: children,
    );
  }
}

/// A special modal barrier that dismisses on tap or pan and
/// offers optional color and blur.
class FloatingToolbarBarrier extends StatelessWidget {
  const FloatingToolbarBarrier({
    super.key,
    required this.onDismiss,
    this.color,
    this.blur,
  });

  /// Callback when this widget receives [GestureTapDownCallback] event or
  /// a [GestureDragStartCallback] event. Which should be whenever user
  /// interacts with an area of the screen NOT over [FloatingToolbar]
  final VoidCallback onDismiss;

  /// Optional color for this barrier
  final Color? color;

  /// Optional blur effect for this barrier
  final ImageFilter? blur;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) => onDismiss(),
      onPanStart: (details) => onDismiss(),
      child: SizedBox.expand(
        child: blur != null
            ? BackdropFilter(
                filter: blur!,
                child: Container(
                  color: color,
                ),
              )
            : Container(
                color: color,
              ),
      ),
    );
  }
}

/// A [ChangeNotifier] for injecting toolbar item selection
class ItemSelector extends ChangeNotifier {
  int? _selected;

  int? get selected => _selected;

  set selected(int? value) {
    _selected = value;
    notifyListeners();
  }
}

/// Encapsulates most of the fields used to create a [FloatingToolbar].
/// The constructor body constructs these from the paramerters.
class _ToolbarBundle {
  /// Derives fields necessary for [FloatingToolbar] from parameters.
  _ToolbarBundle({
    required this.items,
    required this.selectionListenable,
    required this.buttonBuilder,
    required ToolbarAlignment toolbarAlignment,
    required double buttonSpacing,
    required double popupSpacing,
    required EdgeInsets contentPadding,
  }) {
    /// Assign all necessary fields based on [toolbarAlignment]
    switch (toolbarAlignment) {
      case ToolbarAlignment.topLeftVertical:
        alignment = Alignment.topLeft;
        isReversed = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonPadding = EdgeInsets.only(top: buttonSpacing);
        popupPadding = EdgeInsets.only(left: popupSpacing);
        buttonAnchor = Alignment.centerRight;
        popupAnchor = Alignment.centerLeft;
        popupOffset = Offset(contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.centerLeftVertical:
        alignment = Alignment.centerLeft;
        isReversed = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonPadding = EdgeInsets.only(top: buttonSpacing);
        popupPadding = EdgeInsets.only(left: popupSpacing);
        buttonAnchor = Alignment.centerRight;
        popupAnchor = Alignment.centerLeft;
        popupOffset = Offset(contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.bottomLeftVertical:
        alignment = Alignment.bottomLeft;
        isReversed = true;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonPadding = EdgeInsets.only(top: buttonSpacing);
        popupPadding = EdgeInsets.only(left: popupSpacing);
        buttonAnchor = Alignment.centerRight;
        popupAnchor = Alignment.centerLeft;
        popupOffset = Offset(contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.topLeftHorizontal:
        alignment = Alignment.topLeft;
        isReversed = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonPadding = EdgeInsets.only(left: buttonSpacing);
        popupPadding = EdgeInsets.only(top: popupSpacing);
        buttonAnchor = Alignment.bottomCenter;
        popupAnchor = Alignment.topCenter;
        popupOffset = Offset(0.0, contentPadding.bottom);
        break;
      case ToolbarAlignment.topCenterHorizontal:
        alignment = Alignment.topCenter;
        isReversed = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonPadding = EdgeInsets.only(left: buttonSpacing);
        popupPadding = EdgeInsets.only(top: popupSpacing);
        buttonAnchor = Alignment.bottomCenter;
        popupAnchor = Alignment.topCenter;
        popupOffset = Offset(0.0, contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightHorizontal:
        alignment = Alignment.topRight;
        isReversed = true;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonPadding = EdgeInsets.only(left: buttonSpacing);
        popupPadding = EdgeInsets.only(top: popupSpacing);
        buttonAnchor = Alignment.bottomCenter;
        popupAnchor = Alignment.topCenter;
        popupOffset = Offset(0.0, contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightVertical:
        alignment = Alignment.topRight;
        isReversed = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonPadding = EdgeInsets.only(top: buttonSpacing);
        popupPadding = EdgeInsets.only(right: popupSpacing);
        buttonAnchor = Alignment.centerLeft;
        popupAnchor = Alignment.centerRight;
        popupOffset = Offset(-contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.centerRightVertical:
        alignment = Alignment.centerRight;
        isReversed = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonPadding = EdgeInsets.only(top: buttonSpacing);
        popupPadding = EdgeInsets.only(right: popupSpacing);
        buttonAnchor = Alignment.centerLeft;
        popupAnchor = Alignment.centerRight;
        popupOffset = Offset(-contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomRightVertical:
        alignment = Alignment.bottomRight;
        isReversed = true;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonPadding = EdgeInsets.only(top: buttonSpacing);
        popupPadding = EdgeInsets.only(right: popupSpacing);
        buttonAnchor = Alignment.centerLeft;
        popupAnchor = Alignment.centerRight;
        popupOffset = Offset(-contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomLeftHorizontal:
        alignment = Alignment.bottomLeft;
        isReversed = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonPadding = EdgeInsets.only(left: buttonSpacing);
        popupPadding = EdgeInsets.only(bottom: popupSpacing);
        buttonAnchor = Alignment.topCenter;
        popupAnchor = Alignment.bottomCenter;
        popupOffset = Offset(0.0, -contentPadding.top);
        break;
      case ToolbarAlignment.bottomCenterHorizontal:
        alignment = Alignment.bottomCenter;
        isReversed = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonPadding = EdgeInsets.only(left: buttonSpacing);
        popupPadding = EdgeInsets.only(bottom: popupSpacing);
        buttonAnchor = Alignment.topCenter;
        popupAnchor = Alignment.bottomCenter;
        popupOffset = Offset(0.0, -contentPadding.top);
        break;
      case ToolbarAlignment.bottomRightHorizontal:
        alignment = Alignment.bottomRight;
        isReversed = true;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonPadding = EdgeInsets.only(left: buttonSpacing);
        popupPadding = EdgeInsets.only(bottom: popupSpacing);
        buttonAnchor = Alignment.topCenter;
        popupAnchor = Alignment.bottomCenter;
        popupOffset = Offset(0.0, -contentPadding.top);
        break;
    }

    /// Now that the necessary fields are assigned, fill [toolbarButtons]
    /// [popupList], and, [customIndices]
    final bool onlyOneButton = items.length == 1;
    final int lastIndex = items.length - 1;
    for (int index = 0; index < items.length; index++) {
      final FloatingToolbarItem item = items[index];
      final bool noPad =
          onlyOneButton || isReversed ? index == lastIndex : index == 0;
      switch (item.type) {
        case FloatingToolbarItemType.buttonOnly:
          toolbarButtons.add(
            Padding(
              padding: noPad ? EdgeInsets.zero : buttonPadding,
              child: item.basicButton,
            ),
          );
          break;
        case FloatingToolbarItemType.popup:
          final LayerLink targetButtonLink = LayerLink();
          toolbarButtons.add(
            Padding(
              padding: noPad ? EdgeInsets.zero : buttonPadding,
              child: CompositedTransformTarget(
                link: targetButtonLink,
                child: buttonBuilder(index, item),
              ),
            ),
          );
          popupList.add(
            Popup(
              index: index,
              selectionListenable: selectionListenable,
              itemBuilderList: item.popups,
              spacing: popupPadding,
              popupData: FollowerPopupData(
                buttonLink: targetButtonLink,
                direction: popupDirection,
                buttonAnchor: buttonAnchor,
                popupAnchor: popupAnchor,
                popupOffset: popupOffset,
              ),
            ),
          );
          break;
        case FloatingToolbarItemType.custom:
          customIndices.add(index);
          toolbarButtons.add(
            Padding(
              padding: noPad ? EdgeInsets.zero : buttonPadding,
              child: item.custom,
            ),
          );
          break;
      }
    }
  }

  /// All the [FloatingToolbarItem]s contained in a [FloatingToolbar]
  final List<FloatingToolbarItem> items;

  /// The builder used to build an [IconicButton] from a
  /// [FloatingToolbarItem] of type [FloatingToolbarItemType.popup]
  final ItemBuilder buttonBuilder;

  /// The listenable to which buttons + associated popups that are
  /// managed by [FloatingToolbarState] listen.
  final ValueListenable<int?> selectionListenable;

  /// The Axis of the toolbar (vertical or horizontal)
  late final Axis toolbarDirection;

  /// Whether to anchor the last item relative to Alignment
  late final bool isReversed;

  /// Alignment of toolbar in stack
  late final Alignment alignment;

  /// Padding applied to toolbar buttons
  late final EdgeInsets buttonPadding;

  /// Pading applied to popups
  late final EdgeInsets popupPadding;

  /// Axis of popups. Opposite of [toolbarDirection]
  late final Axis popupDirection;

  /// The Alignment from which the button (target) offsets will be measured
  /// by [CompositedTransformFollower]
  late final Alignment buttonAnchor;

  /// The Alignment from which the popup Flex (follower) offsets will be measured
  /// by [CompositedTransformFollower]
  late final Alignment popupAnchor;

  /// The offset used by the [CompositedTransformFollower] enclosing the popup Flex
  late final Offset popupOffset;

  /// The buttons or items shown in the toolbar
  final List<Widget> toolbarButtons = [];

  /// The popups associated with [FloatingToolbarItemType.popup] toolbar buttons
  final List<Widget> popupList = [];

  /// The indices of toolbar items whose selection is not managed
  /// by [FloatingToolbarState]
  final Set<int> customIndices = {};
}
