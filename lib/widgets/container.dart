import 'package:flutter/material.dart';

class ReusableContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final Widget child;
  final BorderRadiusGeometry? borderRadius;

  const ReusableContainer({
    super.key,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}
