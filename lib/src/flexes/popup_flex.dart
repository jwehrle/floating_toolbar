import 'package:flutter/material.dart';
import 'package:floating_toolbar/src/floating_toolbar.dart';
import 'package:floating_toolbar/src/utilities/types.dart';

/// Builds popup buttons associated with itemKey. Listens to
/// [FloatingToolbar$selectionNotifier] and displays buttons iff selection
/// equals itemKey. Transitions are animated with [ScaleTransition].
class PopupFlex extends StatefulWidget {
  final String itemKey;
  final List<Widget> buttons;

  const PopupFlex({
    Key? key,
    required this.itemKey,
    required this.buttons,
  }) : super(key: key);

  PopupFlex.empty({
    Key? key,
    required this.itemKey,
  })  : this.buttons = [],
        super(key: key);

  @override
  State<StatefulWidget> createState() => PopupFlexState();
}

class PopupFlexState extends State<PopupFlex>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final FloatingToolbarState _toolbar;
  bool _showing = false;

  void _selectionListener() {
    if (_toolbar.selectionNotifier.value == null) {
      if (_showing) {
        _showing = false;
        _controller.reverse(from: 1.0);
      }
    } else {
      if (_toolbar.selectionNotifier.value == widget.itemKey) {
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
    _toolbar = FloatingToolbar.of(context);
    _toolbar.selectionNotifier.addListener(_selectionListener);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonData>(
      valueListenable: _toolbar.toolbarButtonDataNotifier,
      builder: (context, buttonData, _) {
        return ValueListenableBuilder<ToolbarData>(
          valueListenable: _toolbar.toolbarDataNotifier,
          builder: (context, toolbarData, _) {
            List<Widget> children = widget.buttons
                .map((b) => ScaleTransition(
                      scale: _controller.view,
                      child: b,
                    ))
                .toList();
            double? width;
            double? height;
            Axis direction;
            switch (toolbarData.alignment) {
              case ToolbarAlignment.topLeftHorizontal:
              case ToolbarAlignment.topCenterHorizontal:
              case ToolbarAlignment.topRightHorizontal:
              case ToolbarAlignment.bottomLeftHorizontal:
              case ToolbarAlignment.bottomCenterHorizontal:
              case ToolbarAlignment.bottomRightHorizontal:
                width = buttonData.effectiveWidth;
                direction = Axis.vertical;
                break;
              case ToolbarAlignment.topLeftVertical:
              case ToolbarAlignment.centerLeftVertical:
              case ToolbarAlignment.bottomLeftVertical:
              case ToolbarAlignment.topRightVertical:
              case ToolbarAlignment.centerRightVertical:
              case ToolbarAlignment.bottomRightVertical:
                height = buttonData.effectiveHeight;
                direction = Axis.horizontal;
                break;
            }
            return Container(
              key: ValueKey(widget.itemKey + '_options_container'),
              width: width,
              height: height,
              alignment: Alignment.center,
              child: Flex(
                direction: direction,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _toolbar.selectionNotifier.removeListener(_selectionListener);
    super.dispose();
  }
}
