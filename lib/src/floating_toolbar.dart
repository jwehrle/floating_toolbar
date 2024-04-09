library floating_toolbar;

import 'package:floating_toolbar/src/widgets/toolbar_button.dart';
import 'package:flutter/material.dart';
import 'package:floating_toolbar/src/utilities/types.dart';

/// Toolbar that aligns to any edge (left, top, right, bottom) with buttons that
/// displays popup buttons above, to the side of, or below the selected toolbar
/// button. FloatingToolbar is also Scrollable and minutely customizable in
/// terms of shapes, colors, highlights, etc.
///
/// The purpose of this Widget is to solve the UX problem of too many buttons
/// on a toolbar such that the user cannot be expected to either know what
/// the toolbar contains or that it scrolls or where the feature they're
/// looking for is. [FloatingToolbar] enables functional organization of buttons
/// that can be shown or hidden by user in an intuitive manner.
class FloatingToolbar extends StatefulWidget {
  FloatingToolbar({
    Key? key,
    required this.data,
    required this.items,
    this.onPressed,
  }) : super(key: key);

  /// Defines characteristics of the toolbar
  final ToolbarData data;

  /// Callback with itemKey of toolbar buttons pressed
  final ValueChanged<String?>? onPressed;

  /// Content of toolbar
  final List<ToolbarItem> items;

  @override
  State<StatefulWidget> createState() => FloatingToolbarState();
}

class FloatingToolbarState extends State<FloatingToolbar> {
  /// Stores currently selected itemKey or null if none is selected.
  final ValueNotifier<String?> _selectionNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    Alignment alignment;
    bool isToolbarReverse;
    Axis toolbarDirection;
    Axis popupDirection;
    EdgeInsets buttonSpacing;
    EdgeInsets popupSpacing;
    Alignment targetAnchor;
    Alignment followerAnchor;
    Offset followerOffset;
    switch (widget.data.alignment) {
      case ToolbarAlignment.topLeftVertical:
        alignment = Alignment.topLeft;
        isToolbarReverse = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(left: widget.data.popupSpacing);
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
        followerOffset = Offset(widget.data.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.centerLeftVertical:
        alignment = Alignment.centerLeft;
        isToolbarReverse = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(left: widget.data.popupSpacing);
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
        followerOffset = Offset(widget.data.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.bottomLeftVertical:
        alignment = Alignment.bottomLeft;
        isToolbarReverse = true;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(left: widget.data.popupSpacing);
        targetAnchor = Alignment.centerRight;
        followerAnchor = Alignment.centerLeft;
        followerOffset = Offset(widget.data.contentPadding.right, 0.0);
        break;
      case ToolbarAlignment.topLeftHorizontal:
        alignment = Alignment.topLeft;
        isToolbarReverse = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(top: widget.data.popupSpacing);
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
        followerOffset = Offset(0.0, widget.data.contentPadding.bottom);
        break;
      case ToolbarAlignment.topCenterHorizontal:
        alignment = Alignment.topCenter;
        isToolbarReverse = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(top: widget.data.popupSpacing);
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
        followerOffset = Offset(0.0, widget.data.contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightHorizontal:
        alignment = Alignment.topRight;
        isToolbarReverse = true;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(top: widget.data.popupSpacing);
        targetAnchor = Alignment.bottomCenter;
        followerAnchor = Alignment.topCenter;
        followerOffset = Offset(0.0, widget.data.contentPadding.bottom);
        break;
      case ToolbarAlignment.topRightVertical:
        alignment = Alignment.topRight;
        isToolbarReverse = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(right: widget.data.popupSpacing);
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
        followerOffset = Offset(-widget.data.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.centerRightVertical:
        alignment = Alignment.centerRight;
        isToolbarReverse = false;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(right: widget.data.popupSpacing);
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
        followerOffset = Offset(-widget.data.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomRightVertical:
        alignment = Alignment.bottomRight;
        isToolbarReverse = true;
        toolbarDirection = Axis.vertical;
        popupDirection = Axis.horizontal;
        buttonSpacing = EdgeInsets.only(top: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(right: widget.data.popupSpacing);
        targetAnchor = Alignment.centerLeft;
        followerAnchor = Alignment.centerRight;
        followerOffset = Offset(-widget.data.contentPadding.left, 0.0);
        break;
      case ToolbarAlignment.bottomLeftHorizontal:
        alignment = Alignment.bottomLeft;
        isToolbarReverse = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(bottom: widget.data.popupSpacing);
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
        followerOffset = Offset(0.0, -widget.data.contentPadding.top);
        break;
      case ToolbarAlignment.bottomCenterHorizontal:
        alignment = Alignment.bottomCenter;
        isToolbarReverse = false;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(bottom: widget.data.popupSpacing);
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
        followerOffset = Offset(0.0, -widget.data.contentPadding.top);
        break;
      case ToolbarAlignment.bottomRightHorizontal:
        alignment = Alignment.bottomRight;
        isToolbarReverse = true;
        toolbarDirection = Axis.horizontal;
        popupDirection = Axis.vertical;
        buttonSpacing = EdgeInsets.only(left: widget.data.buttonSpacing);
        popupSpacing = EdgeInsets.only(bottom: widget.data.popupSpacing);
        targetAnchor = Alignment.topCenter;
        followerAnchor = Alignment.bottomCenter;
        followerOffset = Offset(0.0, -widget.data.contentPadding.top);
        break;
    }
    List<Widget> buttons = [];
    for (int i = 0; i < widget.items.length; i++) {
      ToolbarItem item = widget.items[i];
      String itemKey = item.itemKey;
      if (item.isPopup) {
        buttons.add(
          item.popupButtonBuilder(
            PopupButtonData(
                itemKey: itemKey,
                selectionNotifier: _selectionNotifier,
                size: widget.data.buttonSize,
                onSelectionChanged: widget.onPressed,
                popupSpacing: popupSpacing,
                popupDirection: popupDirection,
                targetAnchor: targetAnchor,
                followerAnchor: followerAnchor,
                followerOffset: followerOffset,
                popupListBuilder: item.popupListBuilder),
          ),
        );
      } else {
        buttons.add(
          item.selectableButtonBuilder(
            SelectableButtonData(
              itemKey: itemKey,
              size: widget.data.buttonSize,
              selectionNotifier: _selectionNotifier,
              onSelectionChanged: widget.onPressed,
            ),
          ),
        );
      }
    }
    List<Widget> children = buttons.isNotEmpty ? [buttons.first] : [];
    for (int index = 1; index < buttons.length; index++) {
      children.add(Padding(padding: buttonSpacing));
      children.add(buttons[index]);
    }
    return Align(
      alignment: alignment,
      child: SingleChildScrollView(
        scrollDirection: toolbarDirection,
        reverse: isToolbarReverse,
        clipBehavior: Clip.none,
        child: Padding(
          padding: widget.data.margin,
          child: Material(
            shape: widget.data.shape,
            color: widget.data.backgroundColor,
            clipBehavior: widget.data.clip,
            elevation: widget.data.elevation,
            child: Padding(
              padding: widget.data.contentPadding,
              child: Flex(
                direction: toolbarDirection,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _selectionNotifier.dispose();
    super.dispose();
  }
}
