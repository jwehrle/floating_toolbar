import 'package:flutter/material.dart';
import 'package:floating_toolbar/flexes/button_flex.dart';
import 'package:floating_toolbar/floating_toolbar.dart';
import 'package:floating_toolbar/utilities/types.dart';

class ToolbarMaterial extends StatelessWidget {
  final List<Widget> buttons;

  const ToolbarMaterial({
    Key? key,
    required this.buttons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ToolbarData>(
      valueListenable: FloatingToolbar.of(context).toolbarDataNotifier,
      builder: (context, data, _) {
        return Padding(
          padding: data.margin,
          child: Material(
            shape: data.shape,
            color: data.backgroundColor,
            clipBehavior: data.clip,
            elevation: data.elevation,
            child: Padding(
              padding: data.contentPadding,
              child: ButtonFlex(
                buttons: buttons,
              ),
            ),
          ),
        );
      },
    );
  }
}
