library floating_toolbar;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:collection_value_notifier/collection_value_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iconic_button/iconic_button.dart';

import 'package:floating_toolbar/src/popup.dart';

import 'items.dart';

/// Builder for toolbar buttons whose selection is managed by [FloatingToolbar]
typedef ItemBuilder = Widget Function(int index, FloatingToolbarItem item);

/// Default shape of toolbar
const ShapeBorder kDefaultToolbarShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(4.0)),
);

const Duration kDefaultToolbarDuration = Duration(milliseconds: 500);
const Duration kDefaultTooltipWaitDuration = Duration(seconds: 2);
const EdgeInsets kDefaultMargin = EdgeInsets.all(2.0);
const double kDefaultPopupSpacing = 8.0;
const double kDefaultButtonSpacing = 4.0;
const EdgeInsets kDefaultContentPadding = EdgeInsets.all(4.0);

/// Center bottom horizontal toolbar style
const ToolbarStyle kDefaultToolbarStyle = const ToolbarStyle(
  alignment: Alignment.bottomCenter,
  isReversed: false,
  popupDirection: Axis.vertical,
  buttonPadding: EdgeInsets.only(left: kDefaultButtonSpacing),
  popupPadding: EdgeInsets.only(bottom: kDefaultPopupSpacing),
  toolbarDirection: Axis.horizontal,
  buttonAnchor: Alignment.topCenter,
  popupAnchor: Alignment.bottomCenter,
  popupOffset: Offset(0.0, -2.0),
  contentPadding: kDefaultContentPadding,
  margin: kDefaultMargin,
  duration: kDefaultToolbarDuration,
  shape: kDefaultToolbarShape,
);

Size _textSize({
  required String text,
  required TextDirection direction,
  required TextStyle? style,
}) {
  TextPainter textPainter = TextPainter()
    ..text = TextSpan(text: text, style: style)
    ..textDirection = direction
    ..maxLines = 1
    ..layout();
  return textPainter.size;
}

double _maxTextWidth(
  BuildContext context,
  List<String> textList,
  TextStyle? textStyle,
) {
  final TextStyle? style = textStyle ?? Theme.of(context).textTheme.bodySmall;
  final TextDirection dir = Directionality.of(context);
  Size max = Size.zero;
  for (var text in textList) {
    Size next = _textSize(text: text, direction: dir, style: style);
    if (next.width > max.width) {
      max = next;
    }
  }
  return max.width;
}

bool _isNotCustom(item) => item.type != FloatingToolbarItemType.custom;

String _itemText(FloatingToolbarItem item) {
  if (item.type == FloatingToolbarItemType.buttonOnly) {
    return item.basicButton.label ?? '';
  }
  if (item.type == FloatingToolbarItemType.popup) {
    return item.popupItem.label ?? '';
  }
  return '';
}

List<String> _toTextList(List<FloatingToolbarItem> items) =>
    items.where(_isNotCustom).toList().map(_itemText).toList();

double _textPadding(
  BuildContext context, [
  EdgeInsetsGeometry? padding,
]) =>
    padding != null
        ? padding.horizontal
        : Theme.of(context).buttonTheme.padding.horizontal;

/// Finds the max width of [items]. This can then be used to size
/// all buttons. Excludes [FloatingToolbarItemType.custom].
double findEqualizedSize({
  required BuildContext context,
  required List<FloatingToolbarItem> items,
  TextStyle? textStyle,
  EdgeInsetsGeometry? padding,
}) =>
    _maxTextWidth(context, _toTextList(items), textStyle) +
    _textPadding(context, padding);

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
  const FloatingToolbar({
    Key? key,
    required this.items,
    this.toolbarStyle = kDefaultToolbarStyle,
    this.toolbarButtonStyle = const ToolbarButtonStyle(),
    this.onValueChanged,
    this.itemSelector,
    this.barrier,
    this.hide = const {},
  }) : super(key: key);

  final ToolbarStyle toolbarStyle;

  final ToolbarButtonStyle toolbarButtonStyle;

  /// Callback with itemKey of toolbar buttons pressed
  final ValueChanged<int?>? onValueChanged;

  /// Used to build the buttons of the toolbar
  final List<FloatingToolbarItem> items;

  /// Optional [ItemSelector] for injecting toolbar item selections.
  final ItemSelector? itemSelector;

  /// Optional barrier to display when popup buttons are visible.
  final ToolbarBarrier? barrier;

  /// Optional Set of indices to hide (useful if you want to change
  /// button visibility dynamically). Changes are animated at [ToolbarStyle.duration]
  final Set<int> hide;

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

  final StreamController<List<Widget>> _popupStrmCtl = StreamController();

  /// Assigns selection value and calls onValueChanged if not null
  void _onTap(int index) {
    _selectNotifier.value = _selectNotifier.value == index ? null : index;
    if (widget.onValueChanged != null) {
      widget.onValueChanged!(index);
    }
  }

  void _deselect(VoidCallback? task) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _selectNotifier.value = null;
      if (widget.onValueChanged != null) {
        widget.onValueChanged!(null);
      }
      if (task != null) {
        task();
      }
    });
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
    widget.itemSelector?.addListener(_selectorListener);
  }

  @override
  void didUpdateWidget(covariant FloatingToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemSelector != oldWidget.itemSelector) {
      oldWidget.itemSelector?.removeListener(_selectorListener);
      widget.itemSelector?.addListener(_selectorListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget toolbar = _ToolbarFlex(
      items: widget.items,
      selectedItemListenable: _selectNotifier,
      toolbarStyle: widget.toolbarStyle,
      hidden: widget.hide,
      onTap: _onTap,
      buttonStyle: widget.toolbarButtonStyle,
      popupListSink: _popupStrmCtl.sink,
      onDeselect: _deselect,
    );
    if (widget.toolbarStyle.useToolbarBody) {
      toolbar = _ToolbarMaterial(
        style: widget.toolbarStyle,
        toolbar: toolbar,
      );
    }
    toolbar = _ToolbarLayout(
      style: widget.toolbarStyle,
      toolbar: toolbar,
    );
    return _ToolbarStack(
      toolbar: toolbar,
      popupStream: _popupStrmCtl.stream,
      animationDuration: widget.toolbarStyle.duration,
      onBarrierDismiss: _barrierDismiss,
      barrier: widget.barrier,
      selectionListenable: _selectNotifier,
    );
  }

  @override
  void dispose() {
    widget.itemSelector?.removeListener(_selectorListener);
    _popupStrmCtl.close();
    super.dispose();
  }
}

class _ToolbarButtonBase extends StatelessWidget {
  final bool isSelected;
  final FloatingToolbarItem item;
  final VoidCallback onTap;
  final ToolbarButtonStyle style;

  const _ToolbarButtonBase({
    required this.isSelected,
    required this.item,
    required this.onTap,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = BaseIconicButton(
      isSelected: isSelected,
      isEnabled: true,
      iconData: item.popupItem.iconData,
      onPressed: onTap,
      label: item.popupItem.label,
      tooltip: item.popupItem.tooltip,
      showAlertDot: style.showAlertDot,
      alertDotColor: style.alertDotColor,
      style: style.buttonStyle,
      primary: style.primary,
      onPrimary: style.onPrimary,
      onSurface: style.onSurface,
      shadowColor: style.shadowColor,
      elevation: style.elevation,
      textStyle: style.textStyle,
      padding: style.padding,
      shape: style.shape,
      splashFactory: style.splashFactory,
      tooltipOffset: style.tooltipOffset,
      preferTooltipBelow: style.preferTooltipBelow,
      animationDuration: style.changeDuration,
      waitDuration: style.waitDuration,
      curve: style.curve,
    );
    if (style.equalizedSize != null) {
      button = SizedBox(
        width: style.equalizedSize,
        child: button,
      );
    }
    return button;
  }
}

/// Copied from [SizeTransition] for the ability to drive changes
/// through a double parameter [factor] rather than an ValueListenable.
/// Which enabled the use of one [AnimationController] for all buttons
/// even though they animate indipendidently.
/// Added [Opacity] for a better look during transitions. 
class _FractionallyHide extends StatelessWidget {
  const _FractionallyHide({
    required this.axis,
    required this.axisAlignment,
    required this.factor,
    required this.child,
  });

  final Axis axis;
  final double axisAlignment;
  final double factor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AlignmentDirectional alignment;
    if (axis == Axis.vertical) {
      alignment = AlignmentDirectional(-1.0, axisAlignment);
    } else {
      alignment = AlignmentDirectional(axisAlignment, -1.0);
    }
    return ClipRect(
      child: Align(
        alignment: alignment,
        heightFactor: axis == Axis.vertical ? math.max(factor, 0.0) : null,
        widthFactor: axis == Axis.horizontal ? math.max(factor, 0.0) : null,
        child: Opacity(
          opacity: factor,
          child: child,
        ),
      ),
    );
  }
}

typedef EvaluateFactor = double Function(double factor);
typedef EvaluateSelection = bool Function(int? selection);

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.evaluateSelection,
    required this.selectionListenable,
    required this.animation,
    required this.evaluateFactor,
    required this.axis,
    required this.axisAlignment,
    required this.padding,
    required this.link,
    required this.item,
    required this.onTap,
    required this.style,
  });

  final EvaluateSelection evaluateSelection;
  final ValueListenable<int?> selectionListenable;
  final ValueListenable<double> animation;
  final EvaluateFactor evaluateFactor;
  final Axis axis;
  final double axisAlignment;
  final EdgeInsets padding;
  final LayerLink link;
  final FloatingToolbarItem item;
  final VoidCallback onTap;
  final ToolbarButtonStyle style;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: selectionListenable,
      builder: (context, selected, _) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return _FractionallyHide(
              axis: axis,
              axisAlignment: axisAlignment,
              factor: evaluateFactor(animation.value),
              child: Padding(
                padding: padding,
                child: CompositedTransformTarget(
                  link: link,
                  child: _ToolbarButtonBase(
                    isSelected: evaluateSelection(selected),
                    item: item,
                    onTap: onTap,
                    style: style,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// The Flex of toolbar buttons that forms the always-visible part of
/// every [FloatingToolbar]
class _ToolbarFlex extends StatefulWidget {
  /// Creates the Flex of toolbar buttons that forms the always-visible part of
  /// every [FloatingToolbar].
  _ToolbarFlex({
    required this.items,
    required this.toolbarStyle,
    required this.hidden,
    required this.onTap,
    required this.buttonStyle,
    required this.popupListSink,
    required this.onDeselect,
    required this.selectedItemListenable,
  });

  /// All the [FloatingToolbarItem]s contained in a [FloatingToolbar]
  final List<FloatingToolbarItem> items;
  final ToolbarStyle toolbarStyle;
  final Set<int> hidden;
  final ValueChanged<int> onTap;
  final ToolbarButtonStyle buttonStyle;
  final Sink<List<Widget>> popupListSink;
  final ValueChanged<VoidCallback?> onDeselect;
  final ValueListenable<int?> selectedItemListenable;

  @override
  State<_ToolbarFlex> createState() => _ToolbarFlexState();
}

class _ToolbarFlexState extends State<_ToolbarFlex>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Set<int> _prevHiddenIndices = {};
  Set<int> _nextHiddenIndices = {};
  Set<int> _hidingIndices = {};
  Set<int> _showingIndices = {};
  ListNotifier<Widget>? _buttonNotifier;

  /// Whether animation is reversing or at beginning
  bool get isShrinking =>
      _controller.status == AnimationStatus.reverse ||
      _controller.status == AnimationStatus.dismissed;

  /// Whether animation is going forward or is at end
  bool get isGrowing =>
      _controller.status == AnimationStatus.forward ||
      _controller.status == AnimationStatus.completed;

  /// Compares [_prevHiddenIndices] and [_nextHiddenIndices] and stores
  /// differences in [_hidingIndices] and [_showingIndices] for later reference.
  /// Returns whether any differences are found.
  bool _hiddenIndicesChange() {
    _hidingIndices = _nextHiddenIndices.difference(_prevHiddenIndices);
    _showingIndices = _prevHiddenIndices.difference(_nextHiddenIndices);
    return _hidingIndices.isNotEmpty || _showingIndices.isNotEmpty;
  }

  /// Drives animation regardless of whether animation is at beginning
  /// or end
  void _animate() {
    if (_controller.isCompleted) {
      _controller.reverse();
    }
    if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  /// Indirectly calls [_animate] if not currently animating.
  /// Passes _animate call to [widget.onDeselect] so that 
  /// any popups can be hidden and these animations will start
  /// in the next scheduled frame.
  void _startAnimation() {
    if (_controller.isAnimating) {
      return;
    }
    widget.onDeselect(_animate);
  }

  /// Returns either the animation value or its inverse depending on
  /// whether hiding or showing, and, whether the animation is 
  /// shrinking or growing. Defaults to 1.0.
  double _evaluateFactor(double animation, int index) {
    if (_hidingIndices.contains(index)) {
      return isShrinking ? animation : 1.0 - animation;
    }
    if (_showingIndices.contains(index)) {
      return isGrowing ? animation : 1.0 - animation;
    }
    return 1.0;
  }

  /// Builds buttons and popups. Popups are passed to [widget.popupListSink] and
  /// buttons are passed to [_buttonNotifier]
  void _toolbarInit() {
    /// The buttons or items shown in the toolbar
    final List<Widget> toolbarButtons = [];

    /// The popups associated with [FloatingToolbarItemType.popup] toolbar buttons
    final List<Widget> popupList = [];

    /// The indices of toolbar items whose selection is not managed
    /// by [FloatingToolbarState]
    final bool onlyOneButton = widget.items.length == 1;
    final int lastIndex = widget.items.length - 1;
    final axisAlignment = widget.toolbarStyle.isReversed ? 1.0 : -1.0;
    for (int index = 0; index < widget.items.length; index++) {
      final FloatingToolbarItem item = widget.items[index];
      final bool noPad = onlyOneButton || widget.toolbarStyle.isReversed
          ? index == lastIndex
          : index == 0;
      final padding =
          noPad ? EdgeInsets.zero : widget.toolbarStyle.buttonPadding;
      switch (item.type) {
        case FloatingToolbarItemType.buttonOnly:
          toolbarButtons.add(
            Padding(
              padding: padding,
              child: item.basicButton,
            ),
          );
          break;
        case FloatingToolbarItemType.popup:
          final LayerLink targetButtonLink = LayerLink();
          toolbarButtons.add(
            _ToolbarButton(
              link: targetButtonLink,
              item: item,
              onTap: () => widget.onTap(index),
              evaluateSelection: (selection) => selection == index,
              evaluateFactor: (factor) => _evaluateFactor(factor, index),
              selectionListenable: widget.selectedItemListenable,
              animation: _controller.view,
              axis: widget.toolbarStyle.toolbarDirection,
              axisAlignment: axisAlignment,
              padding: padding,
              style: widget.buttonStyle,
            ),
          );
          popupList.add(
            PopupCollection(
              index: index,
              selectionListenable: widget.selectedItemListenable,
              itemBuilderList: item.popups,
              spacing: widget.toolbarStyle.popupPadding,
              duration: widget.buttonStyle.popupDuration,
              popupData: FollowerPopupData(
                buttonLink: targetButtonLink,
                direction: widget.toolbarStyle.popupDirection,
                buttonAnchor: widget.toolbarStyle.buttonAnchor,
                popupAnchor: widget.toolbarStyle.popupAnchor,
                popupOffset: widget.toolbarStyle.popupOffset,
              ),
            ),
          );
          break;
        case FloatingToolbarItemType.custom:
          toolbarButtons.add(
            Padding(
              padding: padding,
              child: item.custom,
            ),
          );
          break;
      }
    }
    if (popupList.isNotEmpty) {
      widget.popupListSink.add(popupList);
    }

    if (_buttonNotifier == null) {
      _buttonNotifier = ListNotifier(toolbarButtons);
    } else {
      _buttonNotifier!.value = toolbarButtons;
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.toolbarStyle.duration,
      value: 1.0,
    );
    _toolbarInit();
    _nextHiddenIndices = widget.hidden;
    if (_hiddenIndicesChange()) {
      _startAnimation();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ToolbarFlex oldWidget) {
    super.didUpdateWidget(oldWidget);
    final listEquals = const DeepCollectionEquality().equals;
    if (!listEquals(oldWidget.items, widget.items) ||
        oldWidget.toolbarStyle != widget.toolbarStyle) {
      widget.onDeselect(null);
      _toolbarInit();
    }
    bool isChanged = widget.hidden.length != oldWidget.hidden.length ||
        widget.hidden.difference(oldWidget.hidden).isNotEmpty;
    /// Increment previous and next hidden indices
    if (isChanged) {
      _prevHiddenIndices = _nextHiddenIndices;
      _nextHiddenIndices = widget.hidden;
      if (_hiddenIndicesChange()) {
        _startAnimation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListListenableBuilder<Widget>(
        valueListenable: _buttonNotifier!,
        builder: (context, toolbarButtons, _) {
          return Flex(
            direction: widget.toolbarStyle.toolbarDirection,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: toolbarButtons,
          );
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonNotifier?.dispose();
    super.dispose();
  }
}

/// Wraps toolbar in [Material]. Used when [FloatingToolbar.useToolbarBody] is true.
class _ToolbarMaterial extends StatelessWidget {
  /// Creates [Material] with [toolbar] as child.
  _ToolbarMaterial({
    required this.style,
    required this.toolbar,
  });

  final ToolbarStyle style;

  /// The toolbar to wrapped.
  final Widget toolbar;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: style.shape,
      color: style.backgroundColor,
      clipBehavior: style.clip,
      elevation: style.elevation,
      animationDuration: style.duration,
      child: AnimatedPadding(
        duration: style.duration,
        padding: style.contentPadding,
        child: toolbar,
      ),
    );
  }
}

/// Wraps [toolbar] in embedding widgets that set alignment, scrolling, directions,
///  anchor, clip, padding, and height.
class _ToolbarLayout extends StatelessWidget {
  /// Creates widget that wraps [toolbar] in embedding widgets that set alignment,
  /// scrolling, directions, anchor, clip, padding, and height.
  const _ToolbarLayout({
    required this.style,
    required this.toolbar,
  });

  final ToolbarStyle style;

  /// The toolbar to wrapped.
  final Widget toolbar;

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: style.duration,
      alignment: style.alignment,
      child: SingleChildScrollView(
        scrollDirection: style.toolbarDirection,
        reverse: style.isReversed,
        clipBehavior: Clip.none,
        child: AnimatedPadding(
          duration: style.duration,
          padding: style.margin,
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
    required this.popupStream,
    required this.animationDuration,
    required this.onBarrierDismiss,
    required this.selectionListenable,
    this.barrier,
  });

  /// The part of [FloatingToolbar] which is always visible
  final Widget toolbar;

  /// The popups associated with managed buttons which appear or
  /// disappear depending on selection status.
  final Stream<List<Widget>> popupStream;

  /// Used to determine whether to show barrier, if barrier is not null
  final ValueListenable<int?> selectionListenable;

  /// Optional barrier to show when popups are shown (when [selectionListenable.value] is not null)
  final ToolbarBarrier? barrier;

  /// Barrier callback used when a [FloatingToolbarBarrier] is
  /// desired during popup display.
  final VoidCallback onBarrierDismiss;

  /// Duration for barrier 
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Widget>>(
        stream: popupStream,
        initialData: [],
        builder: (context, snap) {
          final List<Widget> children = [
            if (barrier != null)
              ValueListenableBuilder<int?>(
                  valueListenable: selectionListenable,
                  builder: (context, selection, _) {
                    return FloatingToolbarBarrier(
                      isActive: selection != null,
                      duration: animationDuration,
                      onDismiss: onBarrierDismiss,
                      barrier: barrier!,
                    );
                  }),
            toolbar,
          ];
          // This null check is not strictly necessary
          // since we provide initialData ...but still
          if (snap.hasData) {
            children.addAll(snap.data!);
          }
          return Stack(
            children: children,
          );
        });
  }
}

/// A special modal barrier that dismisses on tap or pan and
/// offers optional color and blur.
class FloatingToolbarBarrier extends StatelessWidget {
  const FloatingToolbarBarrier({
    super.key,
    required this.isActive,
    required this.onDismiss,
    required this.duration,
    required this.barrier,
  });

  /// Callback when this widget receives [GestureTapDownCallback] event or
  /// a [GestureDragStartCallback] event. Which should be whenever user
  /// interacts with an area of the screen NOT over [FloatingToolbar]
  final VoidCallback onDismiss;

  /// The barrier parameters to use when active
  final ToolbarBarrier barrier;

  /// Whether to enable tap and pan detectors and whether to
  /// show barrier.
  final bool isActive;
  
  /// The duration for animated changes in barrier.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: isActive ? (details) => onDismiss() : null,
      onPanStart: isActive ? (details) => onDismiss() : null,
      child: _AnimatedBarrier(
        duration: duration,
        isActive: isActive,
        sigmaX: barrier.sigmaX,
        sigmaY: barrier.sigmaY,
        color: barrier.color,
      ),
    );
  }
}

/// Animates barrier effect between active and inactive.
class _AnimatedBarrier extends StatefulWidget {
  const _AnimatedBarrier({
    required this.isActive,
    required this.duration,
    required this.color,
    required this.sigmaX,
    required this.sigmaY,
  });

  final bool isActive;
  final Duration duration;

  /// Optional color for this barrier
  final Color color;

  /// sigmaX for blur effect
  final double sigmaX;

  /// sigmaY for blur effect
  final double sigmaY;

  @override
  State<_AnimatedBarrier> createState() => _AnimatedBarrierState();
}

class _AnimatedBarrierState extends State<_AnimatedBarrier>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      value: widget.isActive ? 1.0 : 0.0,
      duration: widget.duration,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _AnimatedBarrier oldWidget) {
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (context, _) {
        return SizedBox.expand(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.sigmaX * _controller.value,
              sigmaY: widget.sigmaY * _controller.value,
            ),
            child: Container(
              color: widget.color
                  .withOpacity(widget.color.opacity * _controller.value),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

class ToolbarStyle {
  /// Const constructor for [ToolbarStyle]. Assigns parameters
  /// directly. Do not use this constructor unless you understand
  /// how the toolbar is positioned and laid out. Intead, use
  /// the factory constructors provided.
  const ToolbarStyle({
    required this.alignment,
    required this.isReversed,
    required this.toolbarDirection,
    required this.popupDirection,
    required this.buttonPadding,
    required this.popupPadding,
    required this.buttonAnchor,
    required this.popupAnchor,
    required this.popupOffset,
    required this.contentPadding,
    required this.margin,
    required this.duration,
    required this.shape,
    this.backgroundColor,
    this.clip = Clip.antiAlias,
    this.elevation = 2.0,
    this.useToolbarBody = true,
  });

  factory ToolbarStyle.topLeftVertical({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.topLeft,
      isReversed: false,
      toolbarDirection: Axis.vertical,
      popupDirection: Axis.horizontal,
      buttonPadding: EdgeInsets.only(top: buttonSpacing),
      popupPadding: EdgeInsets.only(left: popupSpacing),
      buttonAnchor: Alignment.centerRight,
      popupAnchor: Alignment.centerLeft,
      popupOffset: Offset(contentPadding.right, 0.0),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.centerLeftVertical({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.centerLeft,
      isReversed: false,
      toolbarDirection: Axis.vertical,
      popupDirection: Axis.horizontal,
      buttonPadding: EdgeInsets.only(top: buttonSpacing),
      popupPadding: EdgeInsets.only(left: popupSpacing),
      buttonAnchor: Alignment.centerRight,
      popupAnchor: Alignment.centerLeft,
      popupOffset: Offset(contentPadding.right, 0.0),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.bottomLeftVertical({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.bottomLeft,
      isReversed: true,
      toolbarDirection: Axis.vertical,
      popupDirection: Axis.horizontal,
      buttonPadding: EdgeInsets.only(top: buttonSpacing),
      popupPadding: EdgeInsets.only(left: popupSpacing),
      buttonAnchor: Alignment.centerRight,
      popupAnchor: Alignment.centerLeft,
      popupOffset: Offset(contentPadding.right, 0.0),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.topLeftHorizontal({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.topLeft,
      isReversed: false,
      toolbarDirection: Axis.horizontal,
      popupDirection: Axis.vertical,
      buttonPadding: EdgeInsets.only(left: buttonSpacing),
      popupPadding: EdgeInsets.only(top: popupSpacing),
      buttonAnchor: Alignment.bottomCenter,
      popupAnchor: Alignment.topCenter,
      popupOffset: Offset(0.0, contentPadding.bottom),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.topCenterHorizontal({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.topCenter,
      isReversed: false,
      toolbarDirection: Axis.horizontal,
      popupDirection: Axis.vertical,
      buttonPadding: EdgeInsets.only(left: buttonSpacing),
      popupPadding: EdgeInsets.only(top: popupSpacing),
      buttonAnchor: Alignment.bottomCenter,
      popupAnchor: Alignment.topCenter,
      popupOffset: Offset(0.0, contentPadding.bottom),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.topRightHorizontal({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.topRight,
      isReversed: true,
      toolbarDirection: Axis.horizontal,
      popupDirection: Axis.vertical,
      buttonPadding: EdgeInsets.only(left: buttonSpacing),
      popupPadding: EdgeInsets.only(top: popupSpacing),
      buttonAnchor: Alignment.bottomCenter,
      popupAnchor: Alignment.topCenter,
      popupOffset: Offset(0.0, contentPadding.bottom),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.topRightVertical({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.topRight,
      isReversed: false,
      toolbarDirection: Axis.vertical,
      popupDirection: Axis.horizontal,
      buttonPadding: EdgeInsets.only(top: buttonSpacing),
      popupPadding: EdgeInsets.only(right: popupSpacing),
      buttonAnchor: Alignment.centerLeft,
      popupAnchor: Alignment.centerRight,
      popupOffset: Offset(-contentPadding.left, 0.0),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.centerRightVertical({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.centerRight,
      isReversed: false,
      toolbarDirection: Axis.vertical,
      popupDirection: Axis.horizontal,
      buttonPadding: EdgeInsets.only(top: buttonSpacing),
      popupPadding: EdgeInsets.only(right: popupSpacing),
      buttonAnchor: Alignment.centerLeft,
      popupAnchor: Alignment.centerRight,
      popupOffset: Offset(-contentPadding.left, 0.0),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.bottomRightVertical({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.bottomRight,
      isReversed: true,
      toolbarDirection: Axis.vertical,
      popupDirection: Axis.horizontal,
      buttonPadding: EdgeInsets.only(top: buttonSpacing),
      popupPadding: EdgeInsets.only(right: popupSpacing),
      buttonAnchor: Alignment.centerLeft,
      popupAnchor: Alignment.centerRight,
      popupOffset: Offset(-contentPadding.left, 0.0),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.bottomLeftHorizontal({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.bottomLeft,
      isReversed: false,
      toolbarDirection: Axis.horizontal,
      popupDirection: Axis.vertical,
      buttonPadding: EdgeInsets.only(left: buttonSpacing),
      popupPadding: EdgeInsets.only(bottom: popupSpacing),
      buttonAnchor: Alignment.topCenter,
      popupAnchor: Alignment.bottomCenter,
      popupOffset: Offset(0.0, -contentPadding.top),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.bottomCenterHorizontal({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.bottomCenter,
      isReversed: false,
      toolbarDirection: Axis.horizontal,
      popupDirection: Axis.vertical,
      buttonPadding: EdgeInsets.only(left: buttonSpacing),
      popupPadding: EdgeInsets.only(bottom: popupSpacing),
      buttonAnchor: Alignment.topCenter,
      popupAnchor: Alignment.bottomCenter,
      popupOffset: Offset(0.0, -contentPadding.top),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  factory ToolbarStyle.bottomRightHorizontal({
    double buttonSpacing = kDefaultButtonSpacing,
    double popupSpacing = kDefaultPopupSpacing,
    EdgeInsets contentPadding = kDefaultContentPadding,
    EdgeInsets margin = kDefaultMargin,
    Duration duration = kDefaultToolbarDuration,
    ShapeBorder shape = kDefaultToolbarShape,
    Color? backgroundColor,
    Clip? clip,
    double? elevation,
    bool? useToolbarBody,
  }) {
    return ToolbarStyle(
      alignment: Alignment.bottomRight,
      isReversed: true,
      toolbarDirection: Axis.horizontal,
      popupDirection: Axis.vertical,
      buttonPadding: EdgeInsets.only(left: buttonSpacing),
      popupPadding: EdgeInsets.only(bottom: popupSpacing),
      buttonAnchor: Alignment.topCenter,
      popupAnchor: Alignment.bottomCenter,
      popupOffset: Offset(0.0, -contentPadding.top),
      contentPadding: contentPadding,
      margin: margin,
      duration: duration,
      shape: shape,
      backgroundColor: backgroundColor,
      clip: clip ?? Clip.antiAlias,
      elevation: elevation ?? 2.0,
      useToolbarBody: useToolbarBody ?? true,
    );
  }

  /// The Axis of the toolbar (vertical or horizontal)
  final Axis toolbarDirection;

  /// Whether to anchor the last item relative to Alignment
  final bool isReversed;

  /// Alignment of toolbar in stack
  final Alignment alignment;

  /// Padding applied to toolbar buttons.
  final EdgeInsets buttonPadding;

  /// Pading applied to popups
  final EdgeInsets popupPadding;

  /// Axis of popups. Opposite of [toolbarDirection]
  final Axis popupDirection;

  /// The Alignment from which the button (target) offsets will be measured
  /// by [CompositedTransformFollower]
  final Alignment buttonAnchor;

  /// The Alignment from which the popup Flex (follower) offsets will be measured
  /// by [CompositedTransformFollower]
  final Alignment popupAnchor;

  /// The offset used by the [CompositedTransformFollower] enclosing the popup Flex
  final Offset popupOffset;

  /// The padding around the buttons but not between them. Default is 4.0 on
  /// all sides.
  final EdgeInsets contentPadding;

  /// Padding around the toolbar. Default is 2.0 on all sides.
  final EdgeInsets margin;

  /// Animation duration of changes to the toolbar surrounding the buttons.
  /// Applied to changes in alignment, margin, and content padding. Default is
  /// 500 milliseconds
  final Duration duration;

  /// The ShapeBorder of the toolbar. Default is Rounded Rectangle with
  /// BorderRadius of 4.0 on all corners.
  final ShapeBorder shape;

  /// The background of the toolbar. Defaults to [Theme.primaryColor]
  final Color? backgroundColor;

  /// The Clip behavior to assign to the ScrollView the toolbar is wrapped in.
  /// Default is antiAlias.
  final Clip clip;

  /// The elevation of the Material widget the toolbar is wrapped in. Default is
  /// 2.0
  final double elevation;

  /// Wrap toolbar in a Material
  final bool useToolbarBody;

  @override
  String toString() {
    return '_ToolbarBundle(toolbarDirection: $toolbarDirection, isReversed: $isReversed, alignment: $alignment, buttonPadding: $buttonPadding, popupPadding: $popupPadding, popupDirection: $popupDirection, buttonAnchor: $buttonAnchor, popupAnchor: $popupAnchor, popupOffset: $popupOffset, contentPadding: $contentPadding, duration: $duration, backgroundColor: $backgroundColor, clip: $clip, elevation: $elevation, useToolbarBody: $useToolbarBody)';
  }

  @override
  bool operator ==(covariant ToolbarStyle other) {
    if (identical(this, other)) return true;

    return other.toolbarDirection == toolbarDirection &&
        other.isReversed == isReversed &&
        other.alignment == alignment &&
        other.buttonPadding == buttonPadding &&
        other.popupPadding == popupPadding &&
        other.popupDirection == popupDirection &&
        other.buttonAnchor == buttonAnchor &&
        other.popupAnchor == popupAnchor &&
        other.popupOffset == popupOffset &&
        other.contentPadding == contentPadding &&
        other.duration == duration &&
        other.backgroundColor == backgroundColor &&
        other.clip == clip &&
        other.elevation == elevation &&
        other.useToolbarBody == useToolbarBody;
  }

  @override
  int get hashCode {
    return toolbarDirection.hashCode ^
        isReversed.hashCode ^
        alignment.hashCode ^
        buttonPadding.hashCode ^
        popupPadding.hashCode ^
        popupDirection.hashCode ^
        buttonAnchor.hashCode ^
        popupAnchor.hashCode ^
        popupOffset.hashCode ^
        contentPadding.hashCode ^
        duration.hashCode ^
        backgroundColor.hashCode ^
        clip.hashCode ^
        elevation.hashCode ^
        useToolbarBody.hashCode;
  }
}

/// const version of Colors.grey.shade300.withOpacity(0.5) for modal barrier default
const kDefaultBarrierColor = Color(0x80E0E0E0);

class ToolbarBarrier {
  /// Color tint for barrier. Defaults to Colors.grey.shade300.withOpacity(0.5)
  /// (or Color(0x80E0E0E0)). Set to Colors.transparent for no color tint.
  final Color color;

  /// Blur factor in x. Defaults to 2.0. Set to 0.0 for no blur
  final double sigmaX;

  /// Blur factor in y. Defaults to 2.0. Set to 0.0 for no blur
  final double sigmaY;

  /// Collection of parameters used to build a modal barrier.
  const ToolbarBarrier({
    this.color = kDefaultBarrierColor,
    this.sigmaX = 2.0,
    this.sigmaY = 2.0,
  });
}

/// Collection of parameters used to build buttons
class ToolbarButtonStyle {
  const ToolbarButtonStyle({
    this.waitDuration = kDefaultTooltipWaitDuration,
    this.changeDuration = kThemeChangeDuration,
    this.popupDuration = kThemeChangeDuration,
    this.showAlertDot = false,
    this.alertDotColor = Colors.red,
    this.elevation = 0.0,
    this.curve = Curves.linear,
    this.buttonStyle,
    this.primary,
    this.onPrimary,
    this.onSurface,
    this.shadowColor,
    this.textStyle,
    this.padding,
    this.shape,
    this.splashFactory,
    this.tooltipOffset,
    this.preferTooltipBelow,
    this.equalizedSize,
  });

  /// Whether to show an alert dot (usually indicative of a notification) on
  /// top of this button. Defaults to false
  final bool showAlertDot;

  /// The color of the optional alert dot. Defaults to [Colors.red]
  final Color alertDotColor;
  final ButtonStyle? buttonStyle;

  /// The foreground color when selected and background color when unselected.
  final Color? primary;

  /// The background color when selected and foreground color when unselected.
  final Color? onPrimary;

  /// The foreground color when disabled.
  final Color? onSurface;

  /// Color of the shadow when elevation is > 0.0
  final Color? shadowColor;

  /// The elevation of the button, defaults to 0.0
  final double elevation;

  /// The TextStyle of the label, defaults to TextStyle()
  final TextStyle? textStyle;

  /// Padding around the foreground contents of the button. Defaults to
  /// ThemeData.buttonTheme.padding
  final EdgeInsetsGeometry? padding;

  /// The shape of the button, by default a RoundedRectangle with radius of 4.0
  final OutlinedBorder? shape;

  /// The splash factory, defaults to InkRipple.splashFactory
  final InteractiveInkFeatureFactory? splashFactory;

  /// Wait duration applied to button hover triggered tooltips. Default is 2
  /// seconds
  final Duration waitDuration;

  /// Duration applied toolbar button state change animations.
  /// Default is [kThemeChangeDuration]
  final Duration changeDuration;

  /// Duration applied popup button animations.
  /// Default is [kThemeChangeDuration]
  final Duration popupDuration;

  /// Curve applied button state change animations. Applied to
  /// [FloatingToolbarItem.popup]. Default is [Curves.linear]
  final Curve curve;

  /// Offset of tooltips
  final double? tooltipOffset;

  /// Whether to place tooltips below their button by default
  final bool? preferTooltipBelow;

  /// Optional uniform size for all [FloatingToolbarItemType.popup] and
  /// [FloatingToolbarItemType.buttonOnly] items. Either set a size
  /// directly (for example [kMinInteractiveDimension]) or use the
  /// [findEqualizedSize] function provided in this file.
  final double? equalizedSize;

  @override
  String toString() {
    return '_ButtonBundle(showAlertDot: $showAlertDot, alertDotColor: $alertDotColor, toolbarButtonStyle: $buttonStyle, primary: $primary, onPrimary: $onPrimary, onSurface: $onSurface, shadowColor: $shadowColor, buttonElevation: $elevation, textStyle: $textStyle, padding: $padding, buttonShape: $shape, splashFactory: $splashFactory, buttonWaitDuration: $waitDuration, buttonChangeDuration: $changeDuration, buttonCurve: $curve, tooltipOffset: $tooltipOffset, preferTooltipBelow: $preferTooltipBelow, equalizedSize: $equalizedSize, popupDuration: $popupDuration)';
  }

  @override
  bool operator ==(covariant ToolbarButtonStyle other) {
    if (identical(this, other)) return true;

    return other.showAlertDot == showAlertDot &&
        other.alertDotColor == alertDotColor &&
        other.buttonStyle == buttonStyle &&
        other.primary == primary &&
        other.onPrimary == onPrimary &&
        other.onSurface == onSurface &&
        other.shadowColor == shadowColor &&
        other.elevation == elevation &&
        other.textStyle == textStyle &&
        other.padding == padding &&
        other.shape == shape &&
        other.splashFactory == splashFactory &&
        other.waitDuration == waitDuration &&
        other.changeDuration == changeDuration &&
        other.curve == curve &&
        other.tooltipOffset == tooltipOffset &&
        other.preferTooltipBelow == preferTooltipBelow &&
        other.equalizedSize == equalizedSize &&
        other.popupDuration == popupDuration;
  }

  @override
  int get hashCode {
    return showAlertDot.hashCode ^
        alertDotColor.hashCode ^
        buttonStyle.hashCode ^
        primary.hashCode ^
        onPrimary.hashCode ^
        onSurface.hashCode ^
        shadowColor.hashCode ^
        elevation.hashCode ^
        textStyle.hashCode ^
        padding.hashCode ^
        shape.hashCode ^
        splashFactory.hashCode ^
        waitDuration.hashCode ^
        changeDuration.hashCode ^
        curve.hashCode ^
        tooltipOffset.hashCode ^
        preferTooltipBelow.hashCode ^
        equalizedSize.hashCode ^
        popupDuration.hashCode;
  }
}
