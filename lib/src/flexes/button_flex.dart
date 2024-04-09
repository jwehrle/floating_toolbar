import 'package:flutter/material.dart';
import 'package:floating_toolbar/src/floating_toolbar.dart';
import 'package:floating_toolbar/src/utilities/utilities.dart';

class ButtonFlex extends StatelessWidget {
  final List<Widget> buttons;

  const ButtonFlex({
    Key? key,
    required this.buttons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ToolbarData>(
      valueListenable: FloatingToolbar.of(context).toolbarDataNotifier,
      builder: (context, data, _) {
        Axis direction = toolbarAxisFromAlignment(data.alignment);
        EdgeInsets spacing;
        switch (direction) {
          case Axis.horizontal:
            spacing = EdgeInsets.only(left: data.buttonSpacing);
            break;
          case Axis.vertical:
            spacing = EdgeInsets.only(top: data.buttonSpacing);
            break;
        }
        List<Widget> children = buttons.isNotEmpty ? [buttons.first] : [];
        for (int index = 1; index < buttons.length; index++) {
          children.add(Padding(padding: spacing));
          children.add(buttons[index]);
        }
        return Flex(
          direction: direction,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  }
}
