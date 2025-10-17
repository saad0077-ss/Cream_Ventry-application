import 'package:flutter/material.dart';

enum PositionedType { basic, fill, directional }

class CustomPositioned extends StatelessWidget {
  final PositionedType type;
  final Widget child;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? start;
  final double? end;
  final double? width;
  final double? height;
  final TextDirection? textDirection;

  const CustomPositioned({
    super.key,
    required this.type,
    required this.child,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.start,
    this.end,
    this.width,
    this.height,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case PositionedType.basic:
        return Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          width: width,
          height: height,
          child: child,
        );
      case PositionedType.fill:
        return Positioned.fill(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: child,
        );
      case PositionedType.directional:
        if (textDirection == null) {
          throw Exception('textDirection is required for PositionedType.directional');
        }
        return Positioned.directional(
          textDirection: textDirection!,
          start: start,
          end: end,
          top: top,
          bottom: bottom,
          width: width,
          height: height,
          child: child,
        );
    }
  }
}