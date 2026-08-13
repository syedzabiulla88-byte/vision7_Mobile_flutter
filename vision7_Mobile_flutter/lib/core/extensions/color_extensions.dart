import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color withOpacityDouble(double opacity) => withAlpha((opacity * 255).round());

  String toHex() {
    final argb = toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
