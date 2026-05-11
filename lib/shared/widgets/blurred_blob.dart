import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredBlob extends StatelessWidget {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double width;
  final double height;
  final double blur;
  final List<Color> colors;
  final List<double>? stops;

  const BlurredBlob({
    super.key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    required this.width,
    required this.height,
    this.blur = 40,
    required this.colors,
    this.stops,
  });

  factory BlurredBlob.solid({
    double? left,
    double? top,
    double? right,
    double? bottom,
    required double width,
    required double height,
    double blur = 40,
    required Color color,
  }) {
    return BlurredBlob(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      blur: blur,
      colors: [
        color,
        color.withValues(alpha: (color.a * 0.3).clamp(0.0, 1.0)),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: colors,
              stops: stops ?? _defaultStops,
            ),
          ),
        ),
      ),
    );
  }

  List<double> get _defaultStops {
    if (colors.length == 1) return const [0.0];
    if (colors.length == 2) return const [0.0, 1.0];
    if (colors.length == 3) return const [0.0, 0.5, 1.0];
    return List.generate(
      colors.length,
      (i) => i / (colors.length - 1),
    );
  }
}
