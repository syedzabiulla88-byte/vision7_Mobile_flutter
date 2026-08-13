import 'package:flutter/widgets.dart';

class AppShadows {
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: const Color(0x1A000000),
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: const Color(0x1F000000),
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: const Color(0x26000000),
      offset: const Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: const Color(0x14000000),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
}
