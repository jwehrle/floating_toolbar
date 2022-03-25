import 'package:flutter/material.dart';
import 'package:floating_toolbar/src/utilities/types.dart';

double toolbarOffset({
  required ToolbarData toolbarData,
  required BoxConstraints constraints,
  required ButtonData buttonData,
  required int buttonCount,
  double scrollOffset = 0.0,
}) {
  switch (toolbarData.alignment) {
    case ToolbarAlignment.topLeftHorizontal:
    case ToolbarAlignment.bottomLeftHorizontal:
      return toolbarData.margin.left +
          toolbarData.contentPadding.left -
          scrollOffset;
    case ToolbarAlignment.topRightHorizontal:
    case ToolbarAlignment.bottomRightHorizontal:
      return toolbarData.margin.right +
          toolbarData.contentPadding.right -
          scrollOffset;
    case ToolbarAlignment.topLeftVertical:
    case ToolbarAlignment.topRightVertical:
      return toolbarData.margin.top +
          toolbarData.contentPadding.top -
          scrollOffset;
    case ToolbarAlignment.bottomLeftVertical:
    case ToolbarAlignment.bottomRightVertical:
      return toolbarData.margin.bottom +
          toolbarData.contentPadding.bottom -
          scrollOffset;
    case ToolbarAlignment.topCenterHorizontal:
    case ToolbarAlignment.bottomCenterHorizontal:
      return constraints.maxWidth / 2.0;
    case ToolbarAlignment.centerLeftVertical:
    case ToolbarAlignment.centerRightVertical:
      return constraints.maxHeight / 2.0;
  }
}

Axis toolbarAxisFromAlignment(ToolbarAlignment alignment) {
  switch (alignment) {
    case ToolbarAlignment.topLeftHorizontal:
    case ToolbarAlignment.topCenterHorizontal:
    case ToolbarAlignment.topRightHorizontal:
    case ToolbarAlignment.bottomLeftHorizontal:
    case ToolbarAlignment.bottomCenterHorizontal:
    case ToolbarAlignment.bottomRightHorizontal:
      return Axis.horizontal;
    case ToolbarAlignment.topLeftVertical:
    case ToolbarAlignment.centerLeftVertical:
    case ToolbarAlignment.bottomLeftVertical:
    case ToolbarAlignment.topRightVertical:
    case ToolbarAlignment.centerRightVertical:
    case ToolbarAlignment.bottomRightVertical:
      return Axis.vertical;
  }
}

double calculateToolbarSize({
  required ToolbarData toolbarData,
  required ButtonData buttonData,
  required int buttonCount,
}) {
  Axis axis = toolbarAxisFromAlignment(toolbarData.alignment);
  double tileSize = axis == Axis.horizontal
      ? buttonData.effectiveHeight
      : buttonData.effectiveWidth;
  double tileSum = buttonCount * tileSize;
  double interTilePaddingSum = (buttonCount - 1) * toolbarData.buttonSpacing;
  double buttonSection = tileSum + interTilePaddingSum;
  double outerPadding = axis == Axis.horizontal
      ? toolbarData.contentPadding.horizontal
      : toolbarData.contentPadding.vertical;
  double marginSum = toolbarData.margin.horizontal;
  return buttonSection + outerPadding + marginSum;
}

ToolbarAlignment layoutAlignment({
  required BoxConstraints constraints,
  required ToolbarData toolbarData,
  required ButtonData buttonData,
  required int buttonCount,
}) {
  double toolbarSize = calculateToolbarSize(
    toolbarData: toolbarData,
    buttonData: buttonData,
    buttonCount: buttonCount,
  );
  switch (toolbarData.alignment) {
    case ToolbarAlignment.topLeftHorizontal:
      return ToolbarAlignment.topLeftHorizontal;
    case ToolbarAlignment.topCenterHorizontal:
      return toolbarSize > constraints.maxWidth
          ? ToolbarAlignment.topLeftHorizontal
          : ToolbarAlignment.topCenterHorizontal;
    case ToolbarAlignment.topRightHorizontal:
      return ToolbarAlignment.topRightHorizontal;
    case ToolbarAlignment.bottomLeftHorizontal:
      return ToolbarAlignment.bottomLeftHorizontal;
    case ToolbarAlignment.bottomCenterHorizontal:
      return toolbarSize > constraints.maxWidth
          ? ToolbarAlignment.bottomLeftHorizontal
          : ToolbarAlignment.bottomCenterHorizontal;
    case ToolbarAlignment.bottomRightHorizontal:
      return ToolbarAlignment.bottomRightHorizontal;
    case ToolbarAlignment.topLeftVertical:
      return ToolbarAlignment.topLeftVertical;
    case ToolbarAlignment.centerLeftVertical:
      return toolbarSize > constraints.maxHeight
          ? ToolbarAlignment.topLeftVertical
          : ToolbarAlignment.centerLeftVertical;
    case ToolbarAlignment.bottomLeftVertical:
      return ToolbarAlignment.bottomLeftVertical;
    case ToolbarAlignment.topRightVertical:
      return ToolbarAlignment.topRightVertical;
    case ToolbarAlignment.centerRightVertical:
      return toolbarSize > constraints.maxHeight
          ? ToolbarAlignment.topRightVertical
          : ToolbarAlignment.centerRightVertical;
    case ToolbarAlignment.bottomRightVertical:
      return ToolbarAlignment.bottomRightVertical;
  }
}

Positioned positionedItem({
  required int index,
  required double toolbarOffset,
  required ToolbarData toolbarData,
  required ButtonData toolbarButtonData,
  required Widget child,
  required int buttonCount,
}) {
  double offset = itemOffset(
    toolbarOffset: toolbarOffset,
    index: index,
    toolbarData: toolbarData,
    buttonData: toolbarButtonData,
    itemCount: buttonCount,
  );
  double verticalAnchor =
      toolbarButtonData.effectiveHeight + toolbarData.contentPadding.vertical;
  double horizontalAnchor =
      toolbarButtonData.effectiveWidth + toolbarData.contentPadding.horizontal;
  switch (toolbarData.alignment) {
    case ToolbarAlignment.topLeftHorizontal:
    case ToolbarAlignment.topCenterHorizontal:
      return Positioned(
        top: verticalAnchor,
        left: offset,
        right: null,
        bottom: null,
        child: child,
      );
    case ToolbarAlignment.topRightHorizontal:
      return Positioned(
        top: verticalAnchor,
        left: null,
        right: offset,
        bottom: null,
        child: child,
      );
    case ToolbarAlignment.bottomLeftHorizontal:
    case ToolbarAlignment.bottomCenterHorizontal:
      return Positioned(
        top: null,
        left: offset,
        right: null,
        bottom: verticalAnchor,
        child: child,
      );
    case ToolbarAlignment.bottomRightHorizontal:
      return Positioned(
        top: null,
        left: null,
        right: offset,
        bottom: verticalAnchor,
        child: child,
      );
    case ToolbarAlignment.topLeftVertical:
    case ToolbarAlignment.centerLeftVertical:
      return Positioned(
        top: offset,
        left: horizontalAnchor,
        right: null,
        bottom: null,
        child: child,
      );
    case ToolbarAlignment.bottomLeftVertical:
      return Positioned(
        top: null,
        left: horizontalAnchor,
        right: null,
        bottom: offset,
        child: child,
      );
    case ToolbarAlignment.topRightVertical:
    case ToolbarAlignment.centerRightVertical:
      return Positioned(
        top: offset,
        left: null,
        right: horizontalAnchor,
        bottom: null,
        child: child,
      );
    case ToolbarAlignment.bottomRightVertical:
      return Positioned(
        top: null,
        left: null,
        right: horizontalAnchor,
        bottom: offset,
        child: child,
      );
  }
}

bool isReverse(ToolbarAlignment alignment) {
  switch (alignment) {
    case ToolbarAlignment.topLeftHorizontal:
    case ToolbarAlignment.topCenterHorizontal:
    case ToolbarAlignment.bottomLeftHorizontal:
    case ToolbarAlignment.bottomCenterHorizontal:
    case ToolbarAlignment.topLeftVertical:
    case ToolbarAlignment.centerLeftVertical:
    case ToolbarAlignment.topRightVertical:
    case ToolbarAlignment.centerRightVertical:
      return false;
    case ToolbarAlignment.topRightHorizontal:
    case ToolbarAlignment.bottomRightHorizontal:
    case ToolbarAlignment.bottomLeftVertical:
    case ToolbarAlignment.bottomRightVertical:
      return true;
  }
}

double itemOffsetFromEdge({
  required double toolbarOffset,
  required int itemsFromEdge,
  required double contentPadding,
  required double buttonSpacing,
  required double buttonWidth,
  required double buttonHeight,
  required Axis axis,
}) {
  toolbarOffset += contentPadding;
  toolbarOffset += (itemsFromEdge - 1) * buttonSpacing;
  switch (axis) {
    case Axis.horizontal:
      toolbarOffset += itemsFromEdge * buttonWidth;
      break;
    case Axis.vertical:
      toolbarOffset += itemsFromEdge * buttonHeight;
      break;
  }
  return toolbarOffset;
}

double itemOffsetFromCenter({
  required double toolbarOffset,
  required int itemCount,
  required int index,
  required double buttonSize,
  required double buttonSpacing,
}) {
  int centerIndex = (itemCount / 2).floor();
  int indexDiff = index - centerIndex;
  double offset = itemCount.isEven ? buttonSpacing / 2.0 : buttonSize / 2.0;
  offset +=
      itemCount.isEven ? indexDiff * buttonSize : (indexDiff - 1) * buttonSize;
  offset += indexDiff * buttonSpacing;
  return toolbarOffset + offset;
}

double itemOffset({
  required double toolbarOffset,
  required int index,
  required ToolbarData toolbarData,
  required ButtonData buttonData,
  required int itemCount,
}) {
  assert(index < itemCount, 'Out of range error');
  switch (toolbarData.alignment) {
    case ToolbarAlignment.topLeftHorizontal:
    case ToolbarAlignment.bottomLeftHorizontal:
      return itemOffsetFromEdge(
        toolbarOffset: toolbarOffset,
        itemsFromEdge: index,
        axis: Axis.horizontal,
        contentPadding: toolbarData.contentPadding.left,
        buttonSpacing: toolbarData.buttonSpacing,
        buttonWidth: buttonData.effectiveWidth,
        buttonHeight: buttonData.effectiveHeight,
      );
    case ToolbarAlignment.topRightHorizontal:
    case ToolbarAlignment.bottomRightHorizontal:
      return itemOffsetFromEdge(
        toolbarOffset: toolbarOffset,
        itemsFromEdge: (itemCount - 1) - index,
        axis: Axis.horizontal,
        contentPadding: toolbarData.contentPadding.right,
        buttonSpacing: toolbarData.buttonSpacing,
        buttonWidth: buttonData.effectiveWidth,
        buttonHeight: buttonData.effectiveHeight,
      );
    case ToolbarAlignment.topLeftVertical:
    case ToolbarAlignment.topRightVertical:
      return itemOffsetFromEdge(
        toolbarOffset: toolbarOffset,
        itemsFromEdge: index,
        axis: Axis.vertical,
        contentPadding: toolbarData.contentPadding.top,
        buttonSpacing: toolbarData.buttonSpacing,
        buttonWidth: buttonData.effectiveWidth,
        buttonHeight: buttonData.effectiveHeight,
      );
    case ToolbarAlignment.bottomLeftVertical:
    case ToolbarAlignment.bottomRightVertical:
      return itemOffsetFromEdge(
        toolbarOffset: toolbarOffset,
        itemsFromEdge: (itemCount - 1) - index,
        axis: Axis.vertical,
        contentPadding: toolbarData.contentPadding.bottom,
        buttonSpacing: toolbarData.buttonSpacing,
        buttonWidth: buttonData.effectiveWidth,
        buttonHeight: buttonData.effectiveHeight,
      );
    case ToolbarAlignment.topCenterHorizontal:
    case ToolbarAlignment.bottomCenterHorizontal:
      return itemOffsetFromCenter(
        toolbarOffset: toolbarOffset,
        index: index,
        itemCount: itemCount,
        buttonSize: buttonData.effectiveWidth,
        buttonSpacing: toolbarData.buttonSpacing,
      );
    case ToolbarAlignment.centerLeftVertical:
    case ToolbarAlignment.centerRightVertical:
      return itemOffsetFromCenter(
        toolbarOffset: toolbarOffset,
        index: index,
        itemCount: itemCount,
        buttonSize: buttonData.effectiveHeight,
        buttonSpacing: toolbarData.buttonSpacing,
      );
  }
}

Alignment convertAlignment(ToolbarAlignment alignment) {
  switch (alignment) {
    case ToolbarAlignment.bottomCenterHorizontal:
      return Alignment.bottomCenter;
    case ToolbarAlignment.topCenterHorizontal:
      return Alignment.topCenter;
    case ToolbarAlignment.topLeftHorizontal:
    case ToolbarAlignment.topLeftVertical:
      return Alignment.topLeft;
    case ToolbarAlignment.centerLeftVertical:
      return Alignment.centerLeft;
    case ToolbarAlignment.bottomLeftHorizontal:
    case ToolbarAlignment.bottomLeftVertical:
      return Alignment.bottomLeft;
    case ToolbarAlignment.topRightHorizontal:
    case ToolbarAlignment.topRightVertical:
      return Alignment.topRight;
    case ToolbarAlignment.centerRightVertical:
      return Alignment.centerRight;
    case ToolbarAlignment.bottomRightHorizontal:
    case ToolbarAlignment.bottomRightVertical:
      return Alignment.bottomRight;
  }
}

bool tooltipPreferBelow(ToolbarAlignment alignment) {
  switch (alignment) {
    case ToolbarAlignment.topLeftHorizontal:
    case ToolbarAlignment.topCenterHorizontal:
    case ToolbarAlignment.topRightHorizontal:
      return true;
    case ToolbarAlignment.bottomLeftHorizontal:
    case ToolbarAlignment.bottomCenterHorizontal:
    case ToolbarAlignment.bottomRightHorizontal:
      return false;
    case ToolbarAlignment.topLeftVertical:
      return true;
    case ToolbarAlignment.centerLeftVertical:
    case ToolbarAlignment.bottomLeftVertical:
      return false;
    case ToolbarAlignment.topRightVertical:
      return true;
    case ToolbarAlignment.centerRightVertical:
    case ToolbarAlignment.bottomRightVertical:
      return false;
  }
}
