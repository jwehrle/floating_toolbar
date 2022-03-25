import 'package:flutter/material.dart';
import 'package:floating_toolbar/src/flexes/button_flex.dart';
import 'package:floating_toolbar/src/floating_toolbar.dart';
import 'package:floating_toolbar/src/utilities/types.dart';

/// Wraps a [ButtonFlex] in a [Material] defined by the [ToolbarData] of
/// [FloatingToolbar] ancestor.
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
