class AppBreakpoints {
  static const sm = 640.0;
  static const md = 768.0;
  static const lg = 1024.0;
  static const xl = 1280.0;

  static bool isSmallScreen(double width) => width < sm;
  static bool isMediumScreen(double width) => width >= sm && width < md;
  static bool isLargeScreen(double width) => width >= md && width < lg;
  static bool isXLargeScreen(double width) => width >= lg;
}
