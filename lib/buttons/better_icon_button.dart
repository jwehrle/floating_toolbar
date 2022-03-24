import 'dart:math';

import 'package:floating_toolbar/utilities/types.dart';
import 'package:flutter/material.dart';

class BetterIconButton extends StatelessWidget {
  final IconData iconData;
  final Color foregroundColor;
  final Color decorationColor;
  final Color backgroundColor;
  final ButtonShape buttonShape;
  final BorderStyle borderStyle;
  final double internalPadding;
  final double borderWidth;
  final BorderRadiusGeometry borderRadius;
  final bool isMaterialized;
  final double? radius;
  final double? width;
  final double? height;
  final String? label;
  final double? elevation;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool? preferBelow;
  final double? tooltipOffset;

  const BetterIconButton({
    Key? key,
    required this.iconData,
    required this.foregroundColor,
    required this.decorationColor,
    required this.backgroundColor,
    required this.buttonShape,
    required this.borderStyle,
    required this.onPressed,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    this.internalPadding = 2.0,
    this.borderWidth = 0.0,
    this.isMaterialized = false,
    this.radius,
    this.width,
    this.height,
    this.elevation,
    this.label,
    this.tooltip,
    this.preferBelow,
    this.tooltipOffset,
  })  : assert(!(buttonShape == ButtonShape.circle) || radius != null),
        assert(!(buttonShape == ButtonShape.roundedRectangle) ||
            (height != null && width != null)),
        assert(!(buttonShape == ButtonShape.continuousRectangle) ||
            (height != null && width != null)),
        assert(!(buttonShape == ButtonShape.beveledRectangle) ||
            (height != null && width != null)),
        assert(!(buttonShape == ButtonShape.stadium) ||
            (height != null && width != null)),
        assert(!isMaterialized || elevation != null),
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
        outerWidth = width!;
        outerHeight = height!;
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
        outerWidth = width!;
        outerHeight = height!;
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
        outerWidth = width!;
        outerHeight = height!;
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
        outerWidth = width!;
        outerHeight = height!;
        innerWidth = outerWidth - innerOffset;
        iconAlignment =
            label != null ? Alignment.bottomCenter : Alignment.center;
        labelAlignment = Alignment.bottomCenter;
        break;
    }
    Widget button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
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
      ),
    );

    if (isMaterialized) {
      button = Material(
        color: backgroundColor,
        elevation: elevation!,
        shape: outerShapeBorder,
        child: button,
      );
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        verticalOffset: tooltipOffset,
        preferBelow: preferBelow,
        child: button,
      );
    }
    return button;
  }
}
