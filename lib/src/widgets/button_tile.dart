import 'dart:math';

import 'package:floating_toolbar/src/utilities/types.dart';
import 'package:flutter/material.dart';

/// General purpose button body.
class ButtonTile extends StatelessWidget {
  /// An icon is always shown. Will be scaled to fit in tile
  final IconData iconData;

  /// Label is optional. If present will be scaled to fit in the tile
  final String? label;

  /// The color of the icon and label, if present
  final Color foregroundColor;

  /// The color of the inner ShapeDecoration. Coincides with inner ShapeBorder
  final Color decorationColor;

  /// The color of the outer border and Material, isMaterialized is true.\
  final Color backgroundColor;

  /// The shape of the inner and outer ShapeBorder
  final ButtonShape buttonShape;

  /// BorderStyle of the inner ShapeBorder
  final BorderStyle borderStyle;

  /// Padding between icon and label (if present), and, inner ShapeBorder
  final double internalPadding;

  /// BorderWidth of inner ShapeBorder
  final double borderWidth;

  /// BorderRadiusGeometry of both inner and outer ShapeBorder
  final BorderRadiusGeometry borderRadius;

  /// Whether to wrap in a Material
  final bool isMaterialized;

  /// Radius of a CircularBorder ShapeBorder. Must be non-null when buttonShape
  /// is ButtonShape.circle
  final double? radius;

  /// Width of rectangular ShapeBorders. Must be non-null when buttonShape is
  /// not ButtonShape.circle
  final double width;

  /// Height of rectangular ShapeBorders. Must be non-null when buttonShape is
  /// not ButtonShape.circle
  final double height;

  /// Elevation of Material (if used). Default is 0.0
  final double elevation;

  /// Optional tooltip. If non-null tile will be wrapped in Tooltip
  final String? tooltip;

  /// Tooltip location preference. preferTooltipBelow is true.
  final bool? preferTooltipBelow;

  /// Distance from tile Tooltip will be offset. Default is set by theme or
  /// otherwise 24.0
  final double? tooltipOffset;

  const ButtonTile({
    Key? key,
    required this.iconData,
    required this.foregroundColor,
    required this.decorationColor,
    required this.backgroundColor,
    this.buttonShape = ButtonShape.roundedRectangle,
    this.borderStyle = BorderStyle.solid,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.internalPadding = 2.0,
    this.borderWidth = 0.0,
    this.isMaterialized = false,
    this.radius,
    this.width = 45.0,
    this.height = 40.0,
    this.elevation = 0.0,
    this.label,
    this.tooltip,
    this.preferTooltipBelow,
    this.tooltipOffset,
  })  : assert(!(buttonShape == ButtonShape.circle) || radius != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    double outerWidth;
    double outerHeight;
    double innerWidth;
    ShapeBorder outerShapeBorder;
    ShapeBorder innerShapeBorder;
    Alignment iconAlignment;
    Alignment labelAlignment;
    double innerOffset = internalPadding + borderWidth;
    switch (buttonShape) {
      case ButtonShape.circle:
        outerShapeBorder = CircleBorder();
        innerShapeBorder = CircleBorder(
          side: BorderSide(
            color: backgroundColor,
            width: borderWidth,
            style: borderStyle,
          ),
        );
        outerWidth = radius! * 2.0;
        outerHeight = outerWidth;
        innerWidth = (radius! - (innerOffset / 2.0)) * sqrt2;
        iconAlignment =
            label != null ? Alignment.bottomCenter : Alignment.center;
        labelAlignment = Alignment.topCenter;
        break;
      case ButtonShape.roundedRectangle:
        outerShapeBorder = RoundedRectangleBorder(
          borderRadius: borderRadius,
        );
        innerShapeBorder = RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: backgroundColor,
            width: borderWidth,
            style: borderStyle,
          ),
        );
        outerWidth = width;
        outerHeight = height;
        innerWidth = outerWidth - innerOffset;
        iconAlignment =
            label != null ? Alignment.bottomCenter : Alignment.center;
        labelAlignment = Alignment.bottomCenter;
        break;
      case ButtonShape.continuousRectangle:
        outerShapeBorder = ContinuousRectangleBorder(
          borderRadius: borderRadius,
        );
        innerShapeBorder = ContinuousRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: backgroundColor,
            width: borderWidth,
            style: borderStyle,
          ),
        );
        outerWidth = width;
        outerHeight = height;
        innerWidth = outerWidth - innerOffset;
        iconAlignment =
            label != null ? Alignment.bottomCenter : Alignment.center;
        labelAlignment = Alignment.bottomCenter;
        break;
      case ButtonShape.beveledRectangle:
        outerShapeBorder = BeveledRectangleBorder(
          borderRadius: borderRadius,
        );
        innerShapeBorder = BeveledRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: backgroundColor,
            width: borderWidth,
            style: borderStyle,
          ),
        );
        outerWidth = width;
        outerHeight = height;
        innerWidth = outerWidth - innerOffset;
        iconAlignment =
            label != null ? Alignment.bottomCenter : Alignment.center;
        labelAlignment = Alignment.bottomCenter;
        break;
      case ButtonShape.stadium:
        outerShapeBorder = StadiumBorder();
        innerShapeBorder = StadiumBorder(
          side: BorderSide(
            color: backgroundColor,
            width: borderWidth,
            style: borderStyle,
          ),
        );
        outerWidth = width;
        outerHeight = height;
        innerWidth = outerWidth - innerOffset;
        iconAlignment =
            label != null ? Alignment.bottomCenter : Alignment.center;
        labelAlignment = Alignment.bottomCenter;
        break;
    }
    Widget button = Container(
      width: outerWidth,
      height: outerHeight,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        shape: innerShapeBorder,
        color: decorationColor,
      ),
      child: SizedBox(
        width: innerWidth,
        child: label == null
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(iconData, color: foregroundColor),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FittedBox(
                    alignment: iconAlignment,
                    fit: BoxFit.scaleDown,
                    child: Icon(iconData, color: foregroundColor),
                  ),
                  FittedBox(
                    alignment: labelAlignment,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label!,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(color: foregroundColor),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (isMaterialized) {
      button = Material(
        color: backgroundColor,
        elevation: elevation,
        shape: outerShapeBorder,
        child: button,
      );
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        verticalOffset: tooltipOffset,
        preferBelow: preferTooltipBelow,
        child: button,
      );
    }
    return button;
  }
}
