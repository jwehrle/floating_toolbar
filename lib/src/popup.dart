import 'package:collection_value_notifier/collection_value_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconic_button/iconic_button.dart';

/// Encapsulates parameters needed for CompositedTransformFollower on which
/// [Popup] is based.
class FollowerPopupData {
  final LayerLink buttonLink;
  final Axis direction;
  final Alignment buttonAnchor;
  final Alignment popupAnchor;
  final Offset popupOffset;

  FollowerPopupData({
    required this.buttonLink,
    required this.direction,
    required this.buttonAnchor,
    required this.popupAnchor,
    required this.popupOffset,
  });
}

/// Used to build BaseIconicButton popup items. The builder format is required
/// so that ThemeData can be accessed in Widgets using this class from initState
/// Builds an IconicButton equivalent.
class PopupItemBuilder {
  final ButtonController controller;
  final BaseIconicButton Function(
    BuildContext context,
    Set<ButtonState> state,
    Widget? child,
  ) builder;

  PopupItemBuilder({required this.controller, required this.builder});
}

/// Shows or hides popup items which are built from a list of [itemBuilderList]
/// based on [selectionListenable] value comparison to [index].
class Popup extends StatefulWidget {
  const Popup({
    Key? key,
    required this.index,
    required this.selectionListenable,
    required this.itemBuilderList,
    required this.spacing,
    required this.popupData,
  }) : super(key: key);

  /// Which toolbar button this popup is associated with
  final int index;

  /// Event changes in the toolbar button selected determine whether these
  /// popup elements are shown or hidden
  final ValueListenable<int?> selectionListenable;

  /// Builder for each popup element
  final List<PopupItemBuilder> itemBuilderList;

  /// Spacing between popup elements
  final EdgeInsets spacing;

  /// Parameters used for the CompositedTransformFollower on which this calls is
  /// based.
  final FollowerPopupData popupData;

  @override
  State<StatefulWidget> createState() => PopupState();
}

class PopupState extends State<Popup> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

  void _onSelectListener() {
    if (widget.selectionListenable.value == widget.index) {
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
      value: widget.selectionListenable.value == widget.index ? 1.0 : 0.0,
      duration: kThemeAnimationDuration,
    );
    widget.selectionListenable.addListener(_onSelectListener);
  }

  Widget _itemToWidget(PopupItemBuilder item) => Padding(
        padding: widget.spacing,
        child: ScaleTransition(
          scale: _scaleController.view,
          child: SetListenableBuilder<ButtonState>(
            valueListenable: item.controller,
            builder: item.builder,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      top: 0.0,
      child: CompositedTransformFollower(
        link: widget.popupData.buttonLink,
        targetAnchor: widget.popupData.buttonAnchor,
        followerAnchor: widget.popupData.popupAnchor,
        offset: widget.popupData.popupOffset,
        child: Flex(
          direction: widget.popupData.direction,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.itemBuilderList.map(_itemToWidget).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.selectionListenable.removeListener(_onSelectListener);
    _scaleController.dispose();
    super.dispose();
  }
}

class ToolbarModal extends StatefulWidget {
  final ValueListenable<int?> listenable;
  final Alignment alignment;
  final int index;
  final double margin;
  final LayerLink link;
  final Builder builder;

  const ToolbarModal({
    Key? key,
    required this.listenable,
    required this.alignment,
    required this.index,
    required this.link,
    required this.margin,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ToolbarModalState();
}

class ToolbarModalState extends State<ToolbarModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

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
  }

  @override
  Widget build(BuildContext context) {
    double toolbarHeight = widget.link.leaderSize?.height ?? 0.0;
    double bottomPadding = widget.margin + toolbarHeight;
    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: ScaleTransition(
          scale: _scaleController.view,
          child: widget.builder.build(context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onSelectListener);
    _scaleController.dispose();
    super.dispose();
  }
}
