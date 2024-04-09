import 'package:collection_value_notifier/collection_value_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconic_button/iconic_button.dart';

/// Encapsulates parameters needed for CompositedTransformFollower on which
/// [Popup] is based.
class FollowerPopupData {
  final LayerLink link;
  final Axis direction;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;

  FollowerPopupData({
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
    Set<ButtonState> state,
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
    required this.followerPopupData,
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
  final FollowerPopupData followerPopupData;

  @override
  State<StatefulWidget> createState() => PopupState();
}

class PopupState extends State<Popup> with SingleTickerProviderStateMixin {
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
        link: widget.followerPopupData.link,
        targetAnchor: widget.followerPopupData.targetAnchor,
        followerAnchor: widget.followerPopupData.followerAnchor,
        offset: widget.followerPopupData.offset,
        child: Flex(
          direction: widget.followerPopupData.direction,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.itemBuilderList.map(_itemToWidget).toList(),
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
