import 'package:flutter/material.dart';

class SupportMotionTokens {
  const SupportMotionTokens._();

  static const Duration short = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration long = Duration(milliseconds: 320);
  static const Duration shimmer = Duration(milliseconds: 900);

  static const Curve standard = Cubic(0.2, 0, 0, 1);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0, 0.8, 0.15);
}
