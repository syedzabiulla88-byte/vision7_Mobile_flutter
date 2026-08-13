import 'package:flutter/material.dart';

class AppRadius {
  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(16);
  static const xl = Radius.circular(24);

  static BorderRadius circular(double radius) => BorderRadius.circular(radius);

  static const smAll = BorderRadius.all(Radius.circular(8));
  static const mdAll = BorderRadius.all(Radius.circular(12));
  static const lgAll = BorderRadius.all(Radius.circular(16));
  static const xlAll = BorderRadius.all(Radius.circular(24));
}
