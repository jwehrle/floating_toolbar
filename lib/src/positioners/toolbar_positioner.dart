import 'package:flutter/material.dart';
import 'package:floating_toolbar/src/floating_toolbar.dart';
import 'package:floating_toolbar/src/flexes/toolbar_material.dart';
import 'package:floating_toolbar/src/utilities/utilities.dart';

class ToolbarPositioner extends StatelessWidget {
  final ScrollController scrollController;
  final List<Widget> children;

  const ToolbarPositioner({
    Key? key,
    required this.scrollController,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ToolbarData>(
      valueListenable: FloatingToolbar.of(context).toolbarDataNotifier,
      builder: (context, data, _) {
        return Align(
          alignment: convertAlignment(data.alignment),
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: toolbarAxisFromAlignment(data.alignment),
            reverse: isReverse(data.alignment),
            clipBehavior: Clip.none,
            child: ToolbarMaterial(
              buttons: children,
            ),
          ),
        );
      },
    );
  }
}
