import 'package:flutter/material.dart';
import 'package:floating_toolbar/src/flexes/popup_flex.dart';
import 'package:floating_toolbar/src/positioners/positioned_follower.dart';

/// Builds Stack of [PositionedFollowers] which then build [Positioned] in order
/// to locate [PopupFlex] over the index-associated toolbar button.
class PopupPositioner extends StatelessWidget {
  final int buttonCount;
  final List<PopupFlex> children;

  const PopupPositioner({
    Key? key,
    required this.buttonCount,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> popups = [];
    for (int index = 0; index < children.length; index++) {
      final popupFlex = children[index];
      popups.add(
        PositionedFollower(
          index: index,
          child: popupFlex,
          buttonCount: buttonCount,
        ),
      );
    }
    return Stack(
      children: popups,
    );
  }
}
