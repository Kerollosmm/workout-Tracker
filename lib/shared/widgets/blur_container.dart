import 'dart:ui';
import 'package:flutter/material.dart';

class BlurContainer extends StatelessWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final BorderRadius? borderRadius;
  final Color overlayColor;
  final EdgeInsetsGeometry padding;

  const BlurContainer({
    Key? key,
    required this.child,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
    this.borderRadius,
    this.overlayColor = Colors.white10,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: overlayColor,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
