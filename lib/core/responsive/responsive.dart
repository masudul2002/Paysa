import 'package:flutter/widgets.dart';

/// Breakpoints used across the app for responsive decisions.
final class Responsive {
  static bool isPhone(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isLargeTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 1024 && width < 1440;
  }

  static bool isFoldable(BuildContext context) {
    // Placeholder: adapt when foldable APIs are required. Use aspect ratio heuristic.
    final size = MediaQuery.of(context).size;
    return size.width / size.height > 1.6;
  }
}
