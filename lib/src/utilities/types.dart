import 'package:flutter/material.dart';
import 'package:floating_toolbar/src/utilities/operations.dart';

/// Enum of Flutter-supplied ShapeBorders
enum ButtonShape {
  circle,
  roundedRectangle,
  continuousRectangle,
  beveledRectangle,
  stadium,
}

/// Single enum combining Alignment and Axis.
enum ToolbarAlignment {
  topLeftVertical,
  centerLeftVertical,
  bottomLeftVertical,
  topLeftHorizontal,
  topCenterHorizontal,
  topRightHorizontal,
  topRightVertical,
  centerRightVertical,
  bottomRightVertical,
  bottomLeftHorizontal,
  bottomCenterHorizontal,
  bottomRightHorizontal,
}

/// Encapsulates button parameters into an object.
class ButtonData {
  ButtonData({
    required this.accentColor,
    required this.backgroundColor,
    required this.disabledColor,
    this.buttonShape = ButtonShape.roundedRectangle,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(4.0),
    ),
    this.height,
    this.width,
    this.radius,
    this.internalPadding = 2.0,
    this.borderWidth = 0.0,
    this.borderStyle = BorderStyle.solid,
    this.isMaterialized = false,
    this.elevation = 0.0,
  })  : assert(!(buttonShape == ButtonShape.circle) || radius != null),
        assert(!(buttonShape == ButtonShape.roundedRectangle) ||
            (height != null && width != null)),
        assert(!(buttonShape == ButtonShape.continuousRectangle) ||
            (height != null && width != null)),
        assert(!(buttonShape == ButtonShape.beveledRectangle) ||
            (height != null && width != null)),
        assert(!(buttonShape == ButtonShape.stadium) ||
            (height != null && width != null));

  /// The ShapeBorder which will be applied to the button and its inner accent
  /// area. Default is [RoundedRectangle]
  final ButtonShape buttonShape;

  /// The BorderRadiusGeometry applied to the button shape and inner accent
  /// area. Default is circular radius of 4.0 on all corners.
  final BorderRadiusGeometry borderRadius;

  /// The height of the button. Must be supplied for non-circular buttons.
  final double? height;

  /// The width of the button. Must be supplied for non-circular buttons.
  final double? width;

  /// The radius of the button. Must be supplied for circular buttons.
  final double? radius;

  /// Padding between the edge of the highlight area and the button content.
  /// Default is 2.0
  final double internalPadding;

  /// Color used for button highlighting.
  final Color accentColor;

  /// Color used for the background of the button.
  final Color backgroundColor;

  /// Color used to indicate that the button is disabled.
  final Color disabledColor;

  /// The width of the border around the highlighted area. Default is 0.0
  final double borderWidth;

  /// The border style around the highlighted area. Default is solid.
  final BorderStyle borderStyle;

  /// Whether to wrap the button in a Material widget or not. Typically, buttons
  /// in a toolbar are not but solo buttons are. Default is [false].
  final bool isMaterialized;

  /// The elevation to apply to a Material widget wrapped around button. Default
  /// is 2.0
  final double elevation;

  /// Height of button whatever its shape
  double get effectiveHeight =>
      buttonShape == ButtonShape.circle ? radius! * 2.0 : height!;

  /// Width of button whatever its shape
  double get effectiveWidth =>
      buttonShape == ButtonShape.circle ? radius! * 2.0 : width!;

  @override
  String toString() => 'ButtonData: $buttonShape';

  @override
  int get hashCode {
    int hash = buttonShape.hashCode;
    hash %= height.hashCode;
    hash %= width.hashCode;
    hash %= radius.hashCode;
    hash %= internalPadding.hashCode;
    hash %= borderWidth.hashCode;
    hash %= borderStyle.hashCode;
    hash %= borderRadius.hashCode;
    return hash;
  }

  @override
  bool operator ==(Object other) {
    if (other is ButtonData) {
      if (buttonShape != other.buttonShape) {
        return false;
      }
      if (borderRadius != other.borderRadius) {
        return false;
      }
      if (borderWidth != other.borderWidth) {
        return false;
      }
      if (borderStyle != other.borderStyle) {
        return false;
      }
      if (height != other.height) {
        return false;
      }
      if (width != other.width) {
        return false;
      }
      if (radius != other.radius) {
        return false;
      }
      if (internalPadding != other.internalPadding) {
        return false;
      }
      return true;
    }
    return false;
  }
}

/// Encapsulates toolbar parameters into an object
class ToolbarData {
  ToolbarData({
    required this.alignment,
    required this.backgroundColor,
    this.contentPadding = const EdgeInsets.all(2.0),
    this.buttonSpacing = 2.0,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(4.0),
      ),
    ),
    this.margin = const EdgeInsets.all(2.0),
    this.clip = Clip.antiAlias,
    this.elevation = 2.0,
  });

  /// The location of the toolbar. The first direction indicates alignment along
  /// a side, the second direction indicates alignment relative to that side.
  /// For example: leftTop means the toolbar will be placed vertically along the
  /// left side, and, the start of the toolbar will be at the top.
  final ToolbarAlignment alignment;

  /// The background color of the toolbar
  final Color backgroundColor;

  /// The padding around the buttons but not between them. Default is 2.0 on
  /// all sides.
  final EdgeInsets contentPadding;

  /// The padding between buttons in the toolbar. Default is 2.0
  final double buttonSpacing;

  /// The ShapeBorder of the toolbar. Default is Rounded Rectangle with
  /// BorderRadius of 4.0 on all corners.
  final ShapeBorder shape;

  /// Padding around the toolbar. Default is 2.0 on all sides.
  final EdgeInsets margin;

  /// The Clip behavior to assign to the ScrollView the toolbar is wrapped in.
  /// Default is antiAlias.
  final Clip clip;

  /// The elevation of the Material widget the toolbar is wrapped in. Default is
  /// 2.0
  final double elevation;

  /// Creates a version of the current ToolbarData fitted to the BoxConstraints
  /// given. Specifically, if ToolbarAlignment is centered on any side but there
  /// isn't enough room on that side for the entire toolbar to be shown, the
  /// ToolbarAlignment will be changed to the start relative to the current side.
  /// So, for example, if ToolbarAlignment is bottomCenter but there isn't enough
  /// room for the entire toolbar to be shown, ToolbarAlignment will be changed
  /// to bottomLeft.
  /// This feature exists because popup positioning does not work correctly when
  /// centering toolbar in views that are not large enough to show the entire
  /// toolbar. To use this feature, use a LayoutBuilder and a post frame callback
  /// to set ToolbarData with a measured layout.
  ToolbarData fitted(
    BoxConstraints constraints,
    ButtonData buttonData,
    int buttonCount,
  ) {
    return ToolbarData(
      alignment: layoutAlignment(
        constraints: constraints,
        toolbarData: this,
        buttonData: buttonData,
        buttonCount: buttonCount,
      ),
      backgroundColor: backgroundColor,
      contentPadding: contentPadding,
      buttonSpacing: buttonSpacing,
      shape: shape,
      margin: margin,
      clip: clip,
      elevation: elevation,
    );
  }

  @override
  String toString() {
    return 'ToolbarData: ToolbarAlignment $alignment, color $backgroundColor, '
        'content padding $contentPadding, button spacing $buttonSpacing, shape '
        '$shape, margin $margin, clip $clip, elevation $elevation';
  }

  @override
  int get hashCode {
    int hash = backgroundColor.hashCode;
    hash %= contentPadding.hashCode;
    hash %= buttonSpacing.hashCode;
    hash %= shape.hashCode;
    hash %= margin.hashCode;
    hash %= clip.hashCode;
    hash %= elevation.hashCode;
    return hash;
  }

  @override
  bool operator ==(Object other) {
    if (other is ToolbarData) {
      if (backgroundColor != other.backgroundColor) {
        return false;
      }
      if (contentPadding != other.contentPadding) {
        return false;
      }
      if (buttonSpacing != other.buttonSpacing) {
        return false;
      }
      if (shape != other.shape) {
        return false;
      }
      if (margin != other.margin) {
        return false;
      }
      if (clip != other.clip) {
        return false;
      }
      if (elevation != other.elevation) {
        return false;
      }
      return true;
    }
    return false;
  }
}
