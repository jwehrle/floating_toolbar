import 'package:floating_toolbar/src/utilities/types.dart';
import 'package:flutter/material.dart';

/// Builds popup buttons associated with itemKey. Listens to
/// [FloatingToolbar$selectionNotifier] and displays buttons iff selection
/// equals itemKey. Transitions are animated with [ScaleTransition].
class PopupList extends StatefulWidget {
  final PopupListData data;
  final List<Widget> buttons;

  const PopupList({
    Key? key,
    required this.data,
    required this.buttons,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PopupListState();
}

class PopupListState extends State<PopupList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showing = false;

  void _selectionListener() {
    if (widget.data.selectionNotifier.value == null) {
      if (_showing) {
        _showing = false;
        _controller.reverse(from: 1.0);
      }
    } else {
      if (widget.data.selectionNotifier.value == widget.data.itemKey) {
        if (!_showing) {
          _showing = true;
          _controller.forward(from: 0.0);
        }
      } else {
        if (_showing) {
          _showing = false;
          _controller.reverse(from: 1.0);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: kThemeAnimationDuration,
    );
    widget.data.selectionNotifier.addListener(_selectionListener);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      top: 0.0,
      child: CompositedTransformFollower(
        link: widget.data.link,
        targetAnchor: widget.data.targetAnchor,
        followerAnchor: widget.data.followerAnchor,
        offset: widget.data.offset,
        child: Flex(
          direction: widget.data.direction,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.buttons
              .map((button) => Padding(
                    padding: widget.data.spacing,
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
    widget.data.selectionNotifier.removeListener(_selectionListener);
    super.dispose();
  }
}
