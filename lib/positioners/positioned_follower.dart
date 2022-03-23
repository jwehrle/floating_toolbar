import 'package:flutter/material.dart';
import 'package:floating_toolbar/floating_toolbar.dart';
import 'package:floating_toolbar/utilities/utilities.dart';

class PositionedFollower extends StatelessWidget {
  final int index;
  final int buttonCount;
  final Widget child;

  const PositionedFollower({
    Key? key,
    required this.index,
    required this.buttonCount,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: FloatingToolbar.of(context).toolbarOffsetNotifier,
      builder: (context, toolbarOffset, _) {
        return ValueListenableBuilder<ButtonData>(
          valueListenable:
              FloatingToolbar.of(context).toolbarButtonDataNotifier,
          builder: (context, buttonData, _) {
            return ValueListenableBuilder<ToolbarData>(
              valueListenable: FloatingToolbar.of(context).toolbarDataNotifier,
              builder: (context, toolbarData, _) {
                return positionedItem(
                  index: index,
                  toolbarOffset: toolbarOffset,
                  toolbarButtonData: buttonData,
                  toolbarData: toolbarData,
                  child: child,
                  buttonCount: buttonCount,
                );
              },
            );
          },
        );
      },
    );
  }
}
